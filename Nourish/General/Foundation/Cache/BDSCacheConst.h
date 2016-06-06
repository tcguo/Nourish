//
//  BDSCacheConst.h
//  BDStockClient
//
//  Created by licheng on 14-10-9.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#ifndef BDStockClient_BDSCacheConst_h
#define BDStockClient_BDSCacheConst_h


//缓存策略
typedef enum  {
    BDSCStorageMemory,          //内存缓存
    BDSCStorageDisk,            //磁盘缓存
    BDSCStorageMemoryAndDisk    //内存和磁盘缓存
}BDSCachePolicy;


#endif
