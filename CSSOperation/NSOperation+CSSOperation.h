//
//  NSOperation+CSSOperation.h
//  CSSOperation
//
//  Created by Joslyn Wu on 2018/4/17.
//  Copyright © 2018年 joslyn. All rights reserved.
//
// https://github.com/JoslynWu/CSSOperation
//

#import <Foundation/Foundation.h>

#pragma mark - NSOperationQueue+CSSOperationStart
@interface NSOperation (CSSOperationStart)

/** 立即执行 */
- (void)syncStart;

/**
 异步执行
 - 如果前一个操作在未完成，那么新操作将被加入队列。执行方式由队列的类型决定（type）
 */
- (void)asyncStart;

/**
 当前操作依赖其它操作.
 - 需要在start之前添加依赖
 */
- (void)addDependencyOperations:(__kindof NSOperation *)newOperation, ...;
- (void)addDependencyArray:(NSArray<__kindof NSOperation *> *)operations;

@end


#pragma mark - NSOperationQueue+CSSOperationDispatchManager
@interface NSOperationQueue (CSSOperationDispatchManager)

/**
 立即执行Operation
 - 不加入队列，直接执行
 */
+ (void)syncStartOperations:(__kindof NSOperation *)newOperation, ...;
+ (void)syncStartArray:(NSArray<__kindof NSOperation *> *)operations;

/**
 异步执行Operation
 - 队列类型由操作具体指定（CSSOperation的type）
 - 队列创建后全局可用
 */
+ (void)asyncStartOperations:(__kindof NSOperation *)newOperation, ...;
+ (void)asyncStartArray:(NSArray<__kindof NSOperation *> *)operations;

@end

