#ifdef __cplusplus
#define DPI_LINKER_DECL  extern "C"
#else
#define DPI_LINKER_DECL
#endif

#include "svdpi.h"
#include "acc.h"

#if 0
    #define PCIE_DPRINTF(fmt, ...)                                           \
    do {                                                                    \
        fprintf(stderr, "PCIE: " fmt, ##__VA_ARGS__);                        \
    } while (0)
#else
    #define PCIE_DPRINTF(fmt, ...)
#endif

//DPI_LINKER_DECL void C_setup_pcie_connection();
//DPI_LINKER_DECL void C_poll(unsigned int* req_type, unsigned long* addr, unsigned int* len, unsigned int* size, unsigned int* strb, unsigned char* data);
//DPI_LINKER_DECL void C_qemu_step();
//DPI_LINKER_DECL void C_req_read(long addr, int width, int len, int id);
//DPI_LINKER_DECL void C_resp_read(long addr, unsigned char* data);
//DPI_LINKER_DECL void C_req_write(long addr, int width, int len, unsigned char* data, unsigned int* strb);
//DPI_LINKER_DECL void C_resp_write();
//DPI_LINKER_DECL void C_req_interrupt(int vector);

//DPI_LINKER_DECL int V_master_read(long addr, int len, int size);
//DPI_LINKER_DECL int V_master_write(long addr, int len, int size, int *strobe, unsigned char *data);
//DPI_LINKER_DECL int V_slave_read(unsigned char *data);

//Globals
zsock_t* qemu_req = NULL;
zsock_t* qemu_resp = NULL;
zsock_t* hdl_req = NULL;
zsock_t* hdl_resp = NULL;
zsock_t* ls_sock  = NULL;
zsock_t* ls_sock2  = NULL;
zpoller_t* poller = NULL;
zframe_t* adv_step = NULL;

//Helpers
uint8_t log2c (uint64_t x) {
    uint8_t log = (x & x-1) ? 1 : 0;
    while (x >>= 1)
        log++;
    return log;
}
/*
uint8_t log2f (uint64_t x) {
    uint8_t log = 0;
    while (x >>= 1)
        log++;
    return log;
}
*/

void C_teardown_pcie_connection() {
    //deinit frame
    zframe_destroy(&adv_step);
    //deinit poller
    zpoller_destroy(&poller);
    //deinit 0mq sockets
    zsock_destroy(&qemu_req);
    zsock_destroy(&qemu_resp);
    zsock_destroy(&hdl_req);
    zsock_destroy(&hdl_resp);
    zsock_destroy(&ls_sock);
    zsock_destroy(&ls_sock2);
    
    printf("PCIE socket connection teardown complete.\n");
}

//DPI functions
void C_setup_pcie_connection() {
    //initialize 0mq sockets
    /*
    qemu_req = zsock_new_pull(">"QEMU_TO_HDL_REQ);     //request from qemu
    qemu_resp = zsock_new_push("@"QEMU_TO_HDL_REP);    //hdl response to request
    hdl_req = zsock_new_push("@"HDL_TO_QEMU_REQ);      //request from hdl
    hdl_resp = zsock_new_pull(">"HDL_TO_QEMU_REP);     //qemu response to request
    ls_sock = zsock_new_push("@"ICOUNT_SOCK);         //icount
    ls_sock2 = zsock_new_push("@"ICOUNT_SOCK2);         //icount
    
    assert(qemu_req && qemu_resp);
    assert(hdl_req && hdl_resp);
    assert(ls_sock);
    assert(ls_sock2);
    */
    
    int port = atoi(getenv("COSIM_PORT"));
    //initialize 0mq sockets
    char buffer[50];
    sprintf(buffer, SOCK_BASE, RECV_SOCK, port);
    qemu_req = zsock_new_pull(buffer);     //request from qemu
    sprintf(buffer, SOCK_BASE, SEND_SOCK, port + 1);
    qemu_resp = zsock_new_push(buffer);    //hdl response to request
    sprintf(buffer, SOCK_BASE, SEND_SOCK, port + 2);
    hdl_req = zsock_new_push(buffer);      //request from hdl
    sprintf(buffer, SOCK_BASE, RECV_SOCK, port + 3);
    hdl_resp = zsock_new_pull(buffer);     //qemu response to request
    sprintf(buffer, SOCK_BASE, SEND_SOCK, port + 6);
    ls_sock = zsock_new_push(buffer);      //lockstep vm1
    sprintf(buffer, SOCK_BASE, SEND_SOCK, port + 7);
    ls_sock2 = zsock_new_push(buffer);     //lockstep vm2

    //set up 0mq poller
    poller = zpoller_new(qemu_req, hdl_resp, NULL);
    assert(poller);

    uint64_t num_instr = ICOUNT_STEP;
    adv_step = zframe_new (&num_instr, sizeof(uint64_t));

    atexit(C_teardown_pcie_connection);

    printf("PCIE socket connection setup complete.\n");
}

static int rd_count = 0;
static int wr_count = 0;
void C_poll(unsigned int* req_type, unsigned long* v_addr, unsigned int* v_len, 
			unsigned int* v_size, unsigned int* v_strb, unsigned char* v_data) {
    zsock_t* sock = zpoller_wait(poller, 0);
    //no useful data
    if (!sock) {
        *req_type = NOOP; //printf("C: poller\n");
        return;
    }
    //useful data
    if (sock == qemu_req) {
        zframe_t* frame = zframe_recv(qemu_req);
        assert(frame);
        ACCData* acc_data = (ACCData*) zframe_data(frame);
        //clear buffer
        //need for both read and write
        uint64_t addr = acc_data->address;
        //uint64_t mask = -1;
        uint32_t size = acc_data->data_size;
        uint32_t axi_size = 0;
        uint32_t axi_len = 0;
        uint32_t align_offset = addr % BUSW;
        //Calculate bursts
        if(size > BUSW)
            axi_len = (size % BUSW) ? size/BUSW : size/BUSW - 1;
        //Calculate size
        axi_size = log2c(size);
        /* Maybe this?
            addr &= mask << log3c(ADDRW);
        */
        //TODO: Read from HDL axi_len times
        //READ from qemu
        if (acc_data->op == READ) {
            printf("C: Q->H RD: addr: %lx\n", addr);
            //Request read from hdl
			*req_type = M_RD;
			*v_addr = addr;
			*v_len = axi_len;
			*v_size = axi_size;
            //Clean resource
            zframe_destroy(&frame);
        }
        //WRITE from qemu
        else {
            //Request write on hdl
			*req_type = M_WR;
            v_strb[0] = (1 << size) - 1;
			v_strb[0] <<= align_offset;
            printf("C: Q->H WR: addr: %lx len: %d size: %d strb: %x\n", addr, axi_len, axi_size, v_strb[0]);
            memcpy(v_data + align_offset, acc_data->data, BUFSZ - align_offset);
            *v_addr = addr;
            *v_len = axi_len;
            *v_size = axi_size;
            //Clean resource
            zframe_destroy(&frame);
        }
    } else if (sock == hdl_resp) {
        //Response from QEMU
        printf("C: H->Q RD\n");
		*req_type = S_RD;
        zframe_t* frame = zframe_recv(hdl_resp);
        assert(frame);
        ACCData* acc_data = (ACCData*) zframe_data(frame);
        uint32_t size = acc_data->data_size;
        //Copy read data to correct location
        uint32_t align_offset = (acc_data->address) % BUSW;
        memcpy(v_data + align_offset, acc_data->data, size);
        //Clean resource
        zframe_destroy(&frame);
    }
}

void C_qemu_step() {
    //int rv = zframe_send(&adv_step, ls_sock, ZFRAME_REUSE + ZFRAME_DONTWAIT);
    zframe_send(&adv_step, ls_sock, ZFRAME_REUSE + ZFRAME_DONTWAIT);
    zframe_send(&adv_step, ls_sock2, ZFRAME_REUSE + ZFRAME_DONTWAIT);
}

void C_req_read(long addr, int width, int len, int id) {
    printf( "C: HDL ->QEMU: Read : RADDR=0x%x, WIDTH=%u, LEN=%u\n", addr, width, len);
    
    int rv;
    uint32_t size = (len + 1) * (1 << width);   

    ACCData acc;
    //memset(&acc, 0, sizeof(ACCData));
    acc.data_size = size;
    acc.address = addr;
    acc.op = READ;
    acc.id = id;
    /* Create frame containing data to send */
    zframe_t* frame = zframe_new (&acc, sizeof(ACCData));
    assert(frame);
    /* Send frame */
    rv = zframe_send(&frame, hdl_req, 0);
    assert(rv == 0);
}

void C_resp_read(long addr, unsigned char* data) {
    printf("C: Q->H RD: addr: %lx complete\n", addr);
    ACCData acc;
    uint32_t align_offset = addr % BUSW;
    //Update data
    memcpy(acc.data, data + align_offset, BUFSZ - align_offset);
    /* Create frame containing data to send */
    zframe_t* frame = zframe_new (&acc, sizeof(ACCData));
    assert(frame);
    //Send response to qemu
    int rv = zframe_send(&frame, qemu_resp, 0);
    assert(rv == 0);
}

void C_resp_write() {
    printf("C: Q->H WR: complete\n");
    ACCData acc;
    //Update data
    /* Create frame containing data to send */
    zframe_t* frame = zframe_new (&acc, sizeof(ACCData));
    assert(frame);
    //Send response to qemu
    int rv = zframe_send(&frame, qemu_resp, 0);
    assert(rv == 0);
}

void C_req_write(long addr, int width, int len, unsigned char* data, unsigned int* strb) {
    printf( "C: HDL ->QEMU: Write: WADDR=0x%x, WIDTH=%u, LEN=%u\n", addr, width, len);
    int rv;
    uint32_t size = (len + 1) * (1 << width);   

    ACCData acc;
    //memset(&acc, 0, sizeof(ACCData));
    acc.data_size = size;
    acc.address = addr;
    acc.op = WRITE;
    /* Copy write data to correct location */
    int i, j, k = 0;
    for(i = 0; i <= len; i++) {
        for(j = 0; j < 32; j++) {
            if(strb[i] & 1) 
                acc.data[k++] = data[(i*32)+j]; 
            strb[i] >>= 1;
        }
    }
    /* Create frame containing data to send */
    zframe_t* frame = zframe_new (&acc, sizeof(ACCData));
    assert(frame);
    /* Send frame */
    rv = zframe_send(&frame, hdl_req, 0);
    assert(rv == 0);
}

void C_req_interrupt(int vector) {
    printf( "C: HDL ->QEMU: INTR: VECTOR=0x%x\n", vector);
    int rv;
    ACCData acc;
    //memset(&acc, 0, sizeof(ACCData));
    acc.op = INTR;
    acc.vector = vector;
    /* Create frame containing data to send */
    zframe_t* frame = zframe_new (&acc, sizeof(ACCData));
    assert(frame);
    /* Send frame */
    rv = zframe_send(&frame, hdl_req, 0);
    assert(rv == 0);
}
