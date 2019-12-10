#include <stdio.h>
#include <stdint.h>

#include <sys/mman.h>

#include <sys/stat.h> 
#include <fcntl.h> // for open
#include <unistd.h> // for close

#include <sys/ioctl.h>

#define SORT_SIZE   (1024) // size of the sorting, in words

/* below for dma buffer mmap */
#define DMA_MMAP_SIZE (4096*128)
int fd_mmap = 0;
void * dma_buffer = NULL;
/* above for dma buffer mmap */
/* below for ioctl*/
#define CDEV_CMD_SORT _IO( 'a', 1 )
int fd_cdev = 0;
/* above for ioctl*/

int main (int argc, char* argv[])
{

    int i, j;
    int * dma_buffer_int = NULL;
    unsigned long testnum = 1;

    /* below for dma buffer mmap */
    fd_mmap = open("/sys/kernel/debug/sort_dma_mmap", O_RDWR);
    if(fd_mmap < 0)
    {
        perror("Open dma mmap file failed");
        return -1;
    }
     
    dma_buffer = mmap(NULL, DMA_MMAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd_mmap, 0);
    if (dma_buffer == MAP_FAILED)
    {
        perror("allocate dma buffer failed");
        return -1;
    }
    dma_buffer_int = (int *)dma_buffer;
    /* above for dma buffer mmap */
 
    /* below for ioctl*/
    if((fd_cdev = open("/dev/sort_cdev", O_RDWR | O_SYNC)) == -1) {
        printf( "open cdev failed.\n");
    }
    /* above for ioctl*/

    /* set and print unsorted data */
    for ( j=0; j<SORT_SIZE; ++j ) {
        *(dma_buffer_int+j) = SORT_SIZE-j;
        printf( "%8x ", *(dma_buffer_int+j) );
        if ( j%8 == 7 )
            printf( "\n");
    }
    printf( "\n");

    /* sort */
    for ( i=0; i<testnum; i++ ) {
        for ( j=0; j<SORT_SIZE; ++j ) {
            *(dma_buffer_int+j) = SORT_SIZE-j;
        }
        if ( ioctl(fd_cdev,CDEV_CMD_SORT)==-1 ) {
            printf("IOCTL trigger sorting failed.\n");
        } else {
            ;
        }

        while ( *(dma_buffer_int+SORT_SIZE-1) == 1 ) ;
    }

    /* print sorted data */
    for ( j=0; j<SORT_SIZE; ++j ) {
        printf( "%8x ", *(dma_buffer_int+j) );
        if ( j%8 == 7 )
        printf( "\n");
    }
    printf( "\n");

    /* below for dma buffer mmap */
    if ( dma_buffer )
        if(munmap(dma_buffer, DMA_MMAP_SIZE) == -1)
            printf( "Unmap dma buffer fained\n" );
    if ( fd_mmap )
        close(fd_mmap);
    /* above for dma buffer mmap */
    /* below for ioctl*/
    close(fd_cdev);
    /* above for ioctl*/

    return 0;
}
