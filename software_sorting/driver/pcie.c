#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

#include <linux/types.h>
#include <linux/device.h>
#include <linux/pci.h>
#include <linux/fs.h>
#include <asm/io.h>

#include <linux/time.h>

#include <linux/proc_fs.h>
#include <linux/seq_file.h>

#include <linux/dma-mapping.h>

#include <linux/kthread.h>  // for threads
#include <asm/cacheflush.h>



#include <linux/debugfs.h>
#include <linux/slab.h>
#include <linux/mm.h>  
 

#include <linux/sched.h>        // included for task_struct
#include <linux/highmem.h>      // included for pagetable walk (kmap_atomic)
#include <asm/pgtable.h>        // included for pagetable
#include <asm/page.h>           // included for pagetable
#include <linux/pid.h>          // included for pid
#include <linux/cdev.h>
#include <linux/errno.h>
#include <linux/ioctl.h>
#include <linux/version.h>
#include <linux/delay.h>        // included for msleep

#define NUM_BARS 1
#define BAR_PERIPHERAL 0

#define PERIPHERAL_OFFSET_BRAM 0x10000000UL
#define PERIPHERAL_OFFSET_UART 0x00000000UL
#define PERIPHERAL_OFFSET_DMA  0x00010000UL
#define PERIPHERAL_OFFSET_SORT 0x00020000UL

struct fpga_pcie_dev
{
	struct pci_dev* pci_dev;
	void * bar[NUM_BARS];
	size_t bar_length[NUM_BARS];
	unsigned long uc_page;
};


struct fpga_pcie_dev* fpga_dev;

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Shenghsun Cho");
MODULE_DESCRIPTION("Linux kernel module for the Sorting hardware.");

/* below for mmap */
void * dma_buffer;
dma_addr_t dma_handle;

#ifndef VM_RESERVED
#define  VM_RESERVED   (VM_DONTEXPAND | VM_DONTDUMP)
#endif

#define PAGES_ORDER_DMA 7

#define SORT_DW     4 // bytes per integer
#define SORT_BW     4 // integers per cycle
#define SORT_SIZE   (1024) // number of total integers
#define DMA_SIZE (4096) // in byte

struct dentry *mmap_file;

struct mmap_info
{
    char *data;            
    int reference;      
};
 
void mmap_open(struct vm_area_struct *vma)
{
    struct mmap_info *info = (struct mmap_info *)vma->vm_private_data;
    info->reference++;
}
 
void mmap_close(struct vm_area_struct *vma)
{
    struct mmap_info *info = (struct mmap_info *)vma->vm_private_data;
    info->reference--;
}
 
static int mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
{
    struct page *page;
    struct mmap_info *info;    
     
    info = (struct mmap_info *)vma->vm_private_data;
    if (!info->data)
    {
        printk("No data\n");
        return 0;    
    }
     
    page = virt_to_page(info->data);    
     
    get_page(page);
    vmf->page = page;            
     
    return 0;
}
 
struct vm_operations_struct mmap_vm_ops =
{
    .open   =   mmap_open,
    .close  =   mmap_close,
    .fault  =   mmap_fault,    
};

int op_mmap(struct file *filp, struct vm_area_struct *vma)
{
    vma->vm_ops = &mmap_vm_ops;
    vma->vm_flags |= VM_RESERVED;    
    vma->vm_private_data = filp->private_data;
    mmap_open(vma);
    return 0;
}
 
int mmapfop_close(struct inode *inode, struct file *filp)
{
    struct mmap_info *info = filp->private_data;
     
    kfree(info);
    filp->private_data = NULL;
    return 0;
}
 
int mmapfop_open(struct inode *inode, struct file *filp)
{
    struct mmap_info *info = kmalloc(sizeof(struct mmap_info), GFP_KERNEL);
    info->data = (char *)dma_buffer;
    /* assign this info struct to the file */
    filp->private_data = info;
    return 0;
}
 
static const struct file_operations mmap_fops = {
    .open       = mmapfop_open,
    .release    = mmapfop_close,
    .mmap       = op_mmap,
};
 
/* above for mmap */

/* below for ioctl */

#define FIRST_MINOR 0
#define MINOR_CNT 1
#define CDEV_CMD_SORT _IO( 'a', 1 )

static dev_t sort_dev;
static struct cdev sort_cdev;
static struct class *cl;

static int sort_cdev_open(struct inode *i, struct file *f)
{
        return 0;
}

static int sort_cdev_close(struct inode *i, struct file *f)
{
        return 0;
}

#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35))
static int  sort_cdev_ioctl(struct inode *i, struct file *f, unsigned int cmd, unsigned long arg)
#else
static long sort_cdev_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
#endif
{
    switch (cmd)
    {
        uint32_t i;
        case CDEV_CMD_SORT:
            iowrite32( 0x10003, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x0 );
            iowrite32( 0x10003, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x30 );
            for ( i=0; i<((SORT_SIZE*SORT_DW)/DMA_SIZE); ++i ) {
                iowrite32( (unsigned int)virt_to_phys(dma_buffer)+(i*DMA_SIZE), fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x18 );
                iowrite32( DMA_SIZE, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x28 );
                while ( ( ioread32( fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x04) & 0x2 ) == 0 ) udelay(10000);
            }
            iowrite32( (SORT_SIZE/SORT_BW), fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_SORT + 0x100 ); // for 1024 x 4 interface
            iowrite32(   1, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_SORT + 0x200 );
            printk(KERN_INFO "Before enable the sorter\n" );
            while ( ioread32( fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_SORT + 0x300 ) == 0 ) udelay(10000);
            printk(KERN_INFO "After  enable the sorter\n" );
            iowrite32(   1, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_SORT + 0x300 );
            iowrite32(   1, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_SORT + 0x400 );
            for ( i=0; i<((SORT_SIZE*SORT_DW)/DMA_SIZE); ++i ) {
                iowrite32( (unsigned int)virt_to_phys(dma_buffer)+(i*DMA_SIZE), fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x48 );
                iowrite32( DMA_SIZE, fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x58 );
                while ( ( ioread32( fpga_dev->bar[BAR_PERIPHERAL] + PERIPHERAL_OFFSET_DMA + 0x34) & 0x2 ) == 0 ) udelay(10000);
            }
            break;
        default:
            return -EINVAL;
    }
 
    return 0;
}

static struct file_operations sort_cdev_fops =
{
    .owner          = THIS_MODULE,
    .open           = sort_cdev_open,
    .release        = sort_cdev_close,
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35))
    .ioctl          = sort_cdev_ioctl
#else
    .unlocked_ioctl = sort_cdev_ioctl
#endif
};


/* above for ioctl */

static DEFINE_PCI_DEVICE_TABLE(fpga_ids) = {
	{PCI_DEVICE(PCI_ANY_ID, 0x0001)},
	{0},
};

MODULE_DEVICE_TABLE(pci, fpga_ids);

static void unmap_bars(void)
{
	int i;
    if ( fpga_dev != NULL ) {
	    for (i = 0; i < NUM_BARS; i++) {
	    	iounmap(fpga_dev->bar[i]);
	    }
    }
}

static void map_bars(struct fpga_pcie_dev* fpga_dev, struct pci_dev *dev)
{
	int i, j=0;
	unsigned long bar_start;
	unsigned long bar_end;
	unsigned long bar_length;
	printk(KERN_INFO "inside map_bars\n");

    for (i = 0; i < 6; i++) {
		printk(KERN_INFO "Mapped BAR %d...\n", i);
		bar_start   = pci_resource_start(dev, i);
		bar_end     = pci_resource_end  (dev, i);
		bar_length  = pci_resource_len  (dev, i);
        if ( bar_length==0) {
		    printk(KERN_INFO "BAR %d is empty\n" , i );
            continue;
        }
		printk(KERN_INFO "BAR %d resource start  = %lx\n" , i, bar_start    );
		printk(KERN_INFO "BAR %d resource end    = %lx\n" , i, bar_end      );
		printk(KERN_INFO "BAR %d resource length = %lx\n" , i, bar_length   );

		fpga_dev->bar[j] = ioremap_nocache(bar_start, bar_length);
	    fpga_dev->bar_length[j] = bar_length;

		printk(KERN_INFO "BAR %d mapped at va %p\n", i, fpga_dev->bar[j]);
        j++;
        if ( j==NUM_BARS)
            break;
	}
}



static ssize_t do_mem_delay(struct file *fp, char *buffer, size_t len, loff_t *offset)
{
	return 0;
}


static const struct file_operations dma_fops = {
    .owner      = THIS_MODULE,
    .read       = do_mem_delay,
};

static int pcie_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
	int ret;
	fpga_dev = NULL;
	
	ret = pci_enable_device(dev);
	
	if (ret < 0) return ret;

	fpga_dev = kzalloc(sizeof(struct fpga_pcie_dev), GFP_KERNEL);
	fpga_dev->pci_dev = dev;

	pci_set_master(dev);
	ret = pci_request_regions(dev, "FPGA_PCI_Device");
	if (ret < 0) {
		printk(KERN_ALERT "Failed to request regions\n");
		pci_disable_device(dev);
		return ret;
	}

	printk(KERN_INFO "Going to map BARs\n");
	map_bars(fpga_dev, dev);

	// Print the physical address of the page, so the userspace can map it later
	printk(KERN_INFO "Uncacheable region at : %lx\n", (unsigned long)virt_to_phys((volatile void *)fpga_dev->uc_page));
		
	ret = dma_set_mask_and_coherent(&(dev->dev), DMA_BIT_MASK(32)); // Check that our device can handle 32 bit addresses. It should be able to, if not bad things happened!
	
	if (ret != 0) { // Returns non-zero on failure
		printk(KERN_ALERT "32 bit DMA not possible!\n");
		pci_disable_device(dev);
		return ret;
	}

	return 0;
}

static void pcie_remove(struct pci_dev *dev)
{
  	pci_release_regions(dev);
  	pci_disable_device(dev);
}

static struct pci_driver pcie_driver = {
	.name = "fpga_pcie",
	.id_table = fpga_ids,
	.probe = pcie_probe,
	.remove = pcie_remove,
};

static int __init pcie_init(void)
{
    int ret = 0;
    struct device *dev_ret;

    printk(KERN_INFO "Init PCI-e ...\n");

    /* below for ioctl */
    if ((ret = alloc_chrdev_region(&sort_dev, FIRST_MINOR, MINOR_CNT, "sort_cdev")) < 0)
    {
        return ret;
    }
 
    cdev_init(&sort_cdev, &sort_cdev_fops);
 
    if ((ret = cdev_add(&sort_cdev, sort_dev, MINOR_CNT)) < 0)
    {
        return ret;
    }
     
    if (IS_ERR(cl = class_create(THIS_MODULE, "char")))
    {
        cdev_del(&sort_cdev);
        unregister_chrdev_region(sort_dev, MINOR_CNT);
        return PTR_ERR(cl);
    }
    if (IS_ERR(dev_ret = device_create(cl, NULL, sort_dev, NULL, "sort_cdev")))
    {
        class_destroy(cl);
        cdev_del(&sort_cdev);
        unregister_chrdev_region(sort_dev, MINOR_CNT);
        return PTR_ERR(dev_ret);
    }

    /* above for ioctl */

    /* below for mmap */
    dma_buffer = (void *)__get_free_pages( GFP_KERNEL | GFP_DMA, PAGES_ORDER_DMA );
    if ( dma_buffer ) {
        printk(KERN_ALERT "Alloc succeed at %p (PHY: 0x%lx).\n", dma_buffer, (unsigned long)virt_to_phys(dma_buffer) );
    }
    else
        printk(KERN_ALERT "Alloc failed.\n" );
    mmap_file = debugfs_create_file("sort_dma_mmap", 0644, NULL, NULL, &mmap_fops);
    /* above for mmap */

    printk(KERN_INFO "Initializing PCI-e ...\n");
	proc_create("fpga_dma", 0, NULL, &dma_fops);

    fpga_dev = NULL;
	ret = pci_register_driver(&pcie_driver);
	return ret; 
}

static void __exit pcie_exit(void)
{
    /* below for mmap */
    if ( dma_buffer ) {
        free_pages( (unsigned long)dma_buffer, PAGES_ORDER_DMA );
    }
    debugfs_remove(mmap_file);
    /* above for mmap */
    /* below for ioctl */
    device_destroy(cl, sort_dev);
    class_destroy(cl);
    cdev_del(&sort_cdev);
    unregister_chrdev_region(sort_dev, MINOR_CNT);
    /* above for ioctl */


    printk(KERN_INFO "Remove PCI-e ...\n");
	remove_proc_entry("fpga_dma", NULL);
    if ( fpga_dev != NULL ) {
	    unmap_bars();
	    pci_unregister_driver(&pcie_driver);
	    kfree(fpga_dev);
    }
}

module_init(pcie_init);
module_exit(pcie_exit);
