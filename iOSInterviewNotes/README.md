# iOSInterview

1. 父类实现深拷贝时，子类如何实现深度拷贝。父类没有实现深拷贝时，子类如何实现深度拷贝
    - 深拷贝与浅拷贝的区别
    浅拷贝是对象指针的拷贝，深拷贝是对象本身内容的复制。
    
    - 父类实现深拷贝时，子类如何实现深度拷贝
    对象实现深拷贝的时候需要实现 `NSCopy` 协议的 `- (void)copyWithZone:` 方法。子类继承父类，同时也继承当前的协议。重写 `- (void)copyWithZone:` 方法，并在内部方法中调用父类的方法，再实现子类中的其他属性内容的 `copy操作`
    
    - 父类没有实现深拷贝时，子类如何实现深度拷贝
    子类需要遵守`NSCopy`协议，且实现 `NSCopy` 协议的 `- (void)copyWithZone:` 方法，出了完成子类属性的 `copy` 操作，还要完成父类的 `copy` 操作


2. KVO，NSNotification，delegate及block区别

- `KVO` 的特点
`KVO`是 `iOS` 中的属性观察器，通过监听key的值的变化，来做出响应，通常用于监听对象的属性变化，是一对多的关系。

- `NSNotification` 的特点
`NSNotification` 需要主动去发动通知，通常用于对状态的监听，可以自己去控制状态变化，使用起来更灵活。它也是一对多的关系。

- `delegate` 的特点
`delegate` 是iOS中的 `代理模式` 的体现。需要用到该类之外的方法业务的类负责将需要用到的方法声明到协议里并交给代理，代理负责找能够完成这些方法的实例，然后对这些完成协议的实例进行引用。在使用的时候直接通过这些实现了协议的实例调用其实现的方法间接完成需要用到的功能方法。

- `block` 的特点
`block` 是iOS中的代码块，本质也是一个对象实例，在运行时阶段创建生成。可以将一个对象实例的部分功能业务逻辑通过 `block 块` 抛出，能够实现同协议一样的功能，而且能够让功能的实现变得更紧凑。


3. `KVC` 如何实现，如何进行键值查找。`KVO` 如何实现

- 搜索规则
赋值过程中，使用 `- (void)setValue:(id)value forKey:(NSString *)key` 或者 `(void)setValue:(id)value forKeyPath:(NSString *)keyPath;` 进行KVC的赋值操作。
在取值过程中，我们会使用 `- (id)valueForKey:(NSString *)key;` 或者 `- (id)valueForKeyPath:(NSString *)keyPath;`。
`KVC`在通过 `key` 或者 `keyPath` 进行操作的时候，可以 `查找属性方法、成员变量` 等，查找的时候可以`兼容多种命名`。

- 查找的时候命名规则
以 `setValue:forKey:` 为例，其内部实现主要有以下步骤：
1. 以 `set<Key>:、_set<Key>`的顺序查找对应命名的 `setter` 方法，如果找到的话，调用这个方法并将值传进去(根据需要进行对象转换)；
2. 如果没有发现 `setter` 方法，但是`accessInstanceVariablesDirectly`类属性返回`YES`，则按`_<key>、_is<Key>、<key>、is<Key>`的顺序查找一个对应的实例变量。如果发现则将 `value` 赋值给实例变量；

3. 如果没有发现 `setter` 方法或实例变量，则调用 `setValue:forUndefinedKey:` 方法，默认抛出一个异常，但是一个`NSObject的子类`可以提出合适的行为。


注意：另外如果设置 `accessInstanceVariablesDirectly` 返回为NO，即使有符合命名规范的实例变量名，`KVC` 无法赋值成功；`setValue:forUndefinedKey:` 默认会抛出一个异常，你可以用重写这个方法用来拦截。


- 取值原理规则
以 `valueForKey:`为例，其内部实现主要有以下几步：

1. 通过 `getter` 方法搜索实例，以 `get<Key>, <key>, is<Key>, _<key>`的顺序搜索符合规则的方法，如果有，就调用对应的方法；

2. 如果没有发现简单 `getter` 方法，并且在类方法 `accessInstanceVariablesDirectly `是返回YES的的情况下搜索一个名为`_<key>、_is<Key>、<key>、is<Key>`的实例；

3. 如果返回值是一个对象指针，则直接返回这个结果；如果返回值是一个基础数据类型，但是这个基础数据类型是被 `NSNumber` 支持的，则存储为 `NSNumber` 并返回；如果返回值是一个不支持 `NSNumber` 的基础数据类型，则通过 `NSValue`进行存储并返回；

4. 在上述情况都失败的情况下调用 `valueForUndefinedKey:` 方法，默认抛出异常，但是子类可以重写此方法。

`KVC` 可以查找 `对象的属性方法` 或者 `成员变量` 等，在查找的时候，查找的时候可以兼容多种命名。

总结来说的话:
设置值先后顺序：
第一阶段：先查找 `setKey` 或者 `_setKey` 查找对应名字的方法，如果存在就对值进行设置
第二阶段：如果在第一阶段没有查找的情况下，判断当前的类方法 `accessInstanceVariablesDirectly` 返回值是否为 `YES`，如果为 `YES` 的情况下，按照下面的顺序查找实例变量，如果查找到实例变量，那么直接将值赋值给 `实例变量` 

1. _key
2. _isKey
3. key
4. isKey

取值的先后顺序也是分为两个阶段：
第一个阶段： 通过 `getter` 方法搜索实例，在搜索过程中，先查找对象中`属性方法`名为 `getKey` 、 `key`、`isKey` 、`_key` 为名字的方法，如果有这些方法就直接调用
第二阶段： 如果第一阶段没有查找到对应的方法的情况下，对实例对象中的 `成员变量`，按照下面的顺序进行查找

1. _key
2. _isKey
3. key
4. isKey


4. 将一个函数在主线程执行的4种方法

    - 使用 `GCD` 的 `dispatch_async(dispatch_getmain(), ^(){})`
    
```
dispatch_async(dispatch_getmain, ^{

});

```

   - 使用 `NSThread` 的  `- (void)performSelectorOnMainThread:withObject:waitUntilDone:` 方法来实现
   
```
[self performSelector:@selector(method) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES modes:nil];

[self performSelectorOnMainThread:@selector(method) withObject:nil waitUntilDone:YES];

[[NSThread mainThread] performSelector:@selector(method) withObject:nil];

```
   
- 使用 `NSRunloop` 的 `- (void)performSelectorOnMainThread:withObject:waitUntilDone:` 方法实现
```
[[NSRunLoop mainRunLoop] performSelector:@selector(method) withObject:nil];

```
    
- 使用 `NSOperationQueue` 来实现

```
NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];  //主队列
NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    //需要执行的方法
}];
[mainQueue addOperation:operation];

```


5. 如何让计时器调用一个类方法

实现的方案
 - 可以直接使用 `Timer` 的 `block` 实现方式（ `iOS10`以后）
 - 可以使用 `timer` 绑定对象方法，然后通过对象方法间接调用类方法
 
 `timer` 需要注意的点
 1. `timer` 直接引用 `self` 添加方法的话，会导致 `timer` 与当前对象相互引用的问题，造成内存泄露。
 2. 在适合时机使用 `timer` 的 `invalid方法` 让 `timer` 失效，进而打破两者相互引用导致的内存泄露问题
 3. 正常创建的 `timer` 要加到 `runloop` 的 `model` 中，否则不会生效.
 
 解决循环引用的两种方法：
 1. 如果是在VC中，可以考虑在VC的 `viewWillDisapper` 中调用 `timer` 的失效方法 `- (void)invalid` 来让定时器失效，进而保证其正常释放
 2. 引入第三方实例 `对象C`，将要实现的 `timer` 的方法放入到 `对象C` 中存储， 将 `对象C` 传入到 `timer`中，让 `timer`对其进行引用。这里需要注意，`对象C` 对于 `对象A` 的引用要使用 `弱引用weak` 来确保 `对象A` 能够正常释放，同时在对象A `dealloc` 的时候，调用 `timer` 的 `invalid方法` 解除对 `timer` 的引用，进而让其正常释放 

6. 如何重写类方法
通过 `子类继承` 的方式，在子类中直接重写覆盖父类的类方法，在使用的时候使用 `[self class]` 进行调用，因为根据 `类方法的查找方式` 是`通过实例类对象的isa指针指向类的类对象`，通过 `类对象` 查找对应的方法的。所以应该在当前子类中进行方法查找`保证其优先被调用`。

7. NSTimer创建后，会在哪个线程运行
首先跟 `Runloop` 有关系， 创建 `timer` 之后，`timer` 在哪个线程的 `Runloop` 中就运行在哪个线程中。
通过 `scheduledTimerWithTimeInterval` 创建的 `timer` 会默认加到当前 `timer`线程中的  `Runloop` 中，而正常添加的 `timer` 依据于 `Runloop` 所在的线程来进行区分的。比如：

```
+ (void)timerUse{
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"come on girls~");
    }];
//    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"结束runloop");
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        NSLog(@"结束runloop");
    }];
    [thread start];
    NSLog(@"方法结束");
}

```

8. `id` 和 `NSObject＊` 的区别

-  `id` 可以理解为指向对象的指针。所有oc的对象, id都可以指向，编译器不会做类型检查，id调用任何存在的方法都不会在编译阶段报错，当然如果这个id指向的对象没有这个方法，该崩溃还是会崩溃的。

- `NSObject *` 指向的必须是 `NSObject` 的子类，调用的也只能是 `NSObjec` 里面的方法否则就要做强制类型转换。

不是所有的 `OC对象都是NSObject的子类`，还有一些继承自`NSProxy`。`NSObject *`可指向的类型是 `id的子集`。



