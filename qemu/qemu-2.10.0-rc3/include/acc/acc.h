#include <errno.h>
#include <czmq.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <zmq.h>

// DEVICE SPECS
#define ACC_VENDOR_ID (0x1337)
#define ACC_DEVICE_ID (0x0001)

// BAR REGION OFFSET
#define BAR_OFFSET_BAR0 (0xE0000000U)
#define BAR_OFFSET_BAR2 (0xC0000000U)
// Size of BAR regions
#define REGION_SIZE_BAR0 (512 * (1 << 20)) // 512mb
#define REGION_SIZE_BAR2 (1 * (1 << 30))   // 1g
// Number of MSI Interrupts
#define NUM_MSI_VEC (1)

#define PKTBUFSZ (10000)
#define BUFSZ (4096) /* 4K bytes buffer size */

#define AXI_MAX_SIZE (128)

#define ADDRW (32)
#define BUSW (32)

#define ICOUNT_INIT (100000)
#define ICOUNT_STEP (8)

extern zsock_t *ls_sock;
extern int hdl_lockstep;
extern int hdl_step_size;
extern int64_t hdl_step_count;
extern int catchup_steps;

/*
Provided as an alternative to TCP port sockets
#define QEMU_TO_HDL_REQ "ipc:///tmp/qemu_hdl_request.sock"
#define QEMU_TO_HDL_REP "ipc:///tmp/qemu_hdl_response.sock"
#define HDL_TO_QEMU_REQ "ipc:///tmp/hdl_qemu_request.sock"
#define HDL_TO_QEMU_REP "ipc:///tmp/hdl_qemu_response.sock"
#define NIC_REQ         "ipc:///tmp/nic_request.sock"
#define NIC_REP         "ipc:///tmp/nic_response.sock"
#define ICOUNT_SOCK     "ipc:///tmp/icount.sock"
*/

#define TCP_MODE  "%stcp://127.0.0.1:%d"
#define IPC_MODE  "%sipc:///tmp/cosim-%d.sock"
#define SOCK_BASE TCP_MODE

#define SEND_SOCK "@"
#define RECV_SOCK ">"

#define QEMU_TO_HDL_REQ "tcp://127.0.0.1:21100"
#define QEMU_TO_HDL_REP "tcp://127.0.0.1:21101"
#define HDL_TO_QEMU_REQ "tcp://127.0.0.1:21102"
#define HDL_TO_QEMU_REP "tcp://127.0.0.1:21103"
#define NIC_REQ         "tcp://127.0.0.1:21104"
#define NIC_REP         "tcp://127.0.0.1:21105"
#define ICOUNT_SOCK     "tcp://127.0.0.1:21106"
#define ICOUNT_SOCK2    "tcp://127.0.0.1:21107"

/* Sorting platform */

typedef enum ACCOperations { NOOP, READ, WRITE, INTR } ACCOp;

typedef enum QEMUOperations { M_RD = 1, M_WR, S_RD } QEMUOp;

typedef struct {
  uint32_t id;               /* transaction id - unused */
  uint32_t data_size;        /* size of data sent */
  uint64_t address;          /* address on which operation was made */
  ACCOp op;                  /* type of operation */
  unsigned char data[BUFSZ]; /* data buffer */
  uint32_t vector;           /* interrupt vector */
} ACCData;

typedef struct {
  uint8_t last;
  uint32_t size;
  uint32_t id;
  unsigned char data[BUFSZ]; /* Temporarily 4k max packet size */
} ACCNICData;

typedef struct {
    uint64_t addr;
    uint32_t burst;
    uint32_t size;
} MRDArgs;

typedef struct {
    uint64_t addr;
    uint32_t burst;
    uint32_t size;
    uint32_t strobe;
} MWRArgs;

