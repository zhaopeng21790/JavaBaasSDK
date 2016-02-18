# JavaBaasSDK

#一、SDK介绍与快速入门
##SDK介绍

#二、SDK安装
CocoaPods 是一个强大的管理第三方库的工具，能最大化的简化安装过程。因此我们推荐您使用这个方法来安装SDK。

首先，安装CocoaPods，安装方法具体参考:[《CocoaPods 安装和使用教程》](http://code4app.com/article/cocoapods-install-usage)

CocoaPods安装完毕以后，在项目的根目录下创建一个名为`Podfile`的文件（无扩展名），并添加以下内容

```
pod 'JavaBaasSDK'
```

然后在终端执行`pod install`来安装。安装完毕以后，运行`pod search JavaBaasSDK`以确认SDK安装到本地库。
#三、对象
##3.1 JBObject
`JBObject`是基础对象和数据类型，其本质是一个json字符串。可以像使用`NSDictionary`一样，给`JBObject`赋值取值。

由于与`NSDictionary`的相似性，每个`JBObject`对象都包含若干属性值对，也就是键值对(key-value)。属性值可以直接设定，也可随时添加新属性值。

假如，我们需求一个音乐播放器类型的app，那么我们可以建立一个表名为`Single`（单曲）的`JBObejct`对象，并包含下列属性：

```objc
singer : "张三"; 
songName : "张三的歌";   
length : 241;
```
需要注意的是，以下所列出的为系统保留字段，由系统自动生成或更新，既不可作为属性名使用，也无需开发者进行指定。

```objc
_id    createdAt    
acl    updatedAt    
```

每个`JBObject`都必须有一个与之对应的表名称，用以区分不同类型的数据。例如，单曲这个对象，可以将表名取为`Single`。

那么，现在我们可以创建一个名为"张三的单曲"的单曲对象(Single)：

```objc
JBObject *single = [JBObject objectWithClassName:@"Single"];
[single setObject:@"张三" forKey:@"singer"];   
[single setObject:@"张三的单曲" forKey:@"songName"];  
[single setObject:@(241) forKey:@"length"];
```
##3.2 同步与异步
JavaBaas的SDK同时提供了数据查询、保存、更新等的同步和异步方法。
例如，我们要保存上面创建好的"张三的单曲"的单曲对象：

```objc
//同步方法-保存数据
NSError *error = nil;
[single save:&error];

//异步方法-保存数据
[single saveInBackgroundWithBlock:^(BOOL succeeded, NSError) {
  if (error) {
    //single保存失败
  } else {
    //single保存成功
  }
}];
```
在iOS或OS X中，大部分代码都是在主线程中运行的。但是，当程序在主线程中访问网络时，会经常出现卡顿崩溃，而且在通常情况下，我们需要在一些操作完成后立即运行后面的代码，所以同步方法不放在主线程中运行。

##3.3 检索对象
如果已知objectId，用JBQuery就可以查询到与之相对应的唯一的JBObject。例如，

```objc
JBQuery *query = [JBQuery queryWithClassName:@"Single"];

//同步方法-检索单对象
NSError *error = nil;
JBObject *single = [getObjectOfClass:@"Single" objectId:@"ac31c72291854630824dbe94bf269748" error:&error];

//异步方法-检索单对象
[query getObjectInbackgroudId:@"ac31c72291854630824dbe94bf269748" block:^(JBObject *object, NSError *error) {   
    if (error) {  
     //返回错误，查询失败  
    } else {  
       //查询成功  
    }
}];
```
##3.4 保存对象
如果我们需要发布或上传一首单曲（single），那么，需要调用`save`方法，数据才能被真正保存下来。
例如，将创建好的"张三的单曲"保存到服务器：

```objc
//同步方法-保存数据
NSError *error = nil;
[single save:&error];

//异步方法-保存数据
[single saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
  if (error) {
  //返回错误，保存失败
  } else {
  //保存成功
  }
}];
```
运行上述示例代码后，想要确认保存是否已经生效，可以到云端的数据管理页面查看数据存储情况。如果已经保存成功，那么在Single的数据表中应该显示出以下纪录：

```objc
objectId:"ac31c72291854630824dbe94bf269748", singer: "张三", songName:"张三的单曲", length:251,   
createdAt:"2016-01-03 11:13:39", updatedAt:"2016-01-03 11:13:39"
```
##3.5 更新对象
更新对象相对简单，只需要更新属性，再保存即可。例如：

```objc
//假设我们现在要对上面"张三的单曲"这一单曲对象更新一些属性
[single setObject:@(3000) forKey:@"downloadCount"];
[single saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
  if (error) {
    //更新属性失败
  } else {
    //更新属性成功
  }
}];
```
需要注意的是，更新对象都是针对单个对象的操作，获得对象的`objectId`才可以去更新对象。服务器判断对象是新增还是更新，是根据有无objectId来决定的。

##3.6 删除对象
删除一个`JBObject`对象：

```objc
//同步方法-删除文件
NSError *error = nil;
[single delete:&error];
```
如果需要在删除后进行操作可以使用`deleteInBackgroundWithBlock:`

```objc
//异步方法-删除文件
[single deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
  if (error) {
    //返回失败，删除对象失败
  } else {
    //删除成功
  }
}];
```
##3.7 关联对象
对象可以和其他对象之间相互关联。我们可以把一个JBObject的实例a，当成另一个JBObject的实例b的属性值保存。

例如，一首单曲是隶属一张专辑的，创建一张专辑信息并对应一首单曲，那么，这首单曲就是实例a，而它所属的专辑就是实例b。专辑可以作为单曲的属性保存。因此可以这样写：

```objc
//创建专辑、名称
JBObject *myAlbum = [JBObject objectWithoutDataWithClassName:@"Album" objectId: 1a5b907a272c47fd977708ebf6bfe958];
[myAlbum setObject:@"王五的专辑" forKey:@"title"];

//创建单曲、歌名
JBObject *mySingle = [JBObject objectWithClassName:@"Single"];
[mySingle setObject:@"王五的单曲" forKey:@"songName"];

//为专辑、单曲建立一对一关系
[mySingle setObject:myAlbum forKey:@"album"];

//同时保存myAlbum、mySingle
//同步方法-保存对象
NSError *error = nil;
[mySingle save:&error];

//异步方法-保存对象
[mySingle saveInBackgroudWithBlock:^(BOOL succeeded, NSError *error) {
  if (error) {
    //返回错误，保存失败
  } else {
    //保存成功
  }
}];
```
默认情况下，在获取到一个JBObject对象实例时，与之相关联的JBObject对象的属性值是获取不到的。这些对象除了objectId之外，其他属性值都是空的。例如我们获取到一个单曲对象，而它关联的专辑对象的属性值，除了objectId，其他的名称、发布时间等都是空的，我们要得到全部这些属性数据，用include来获得关联对象的所有属性：

```objc
JBQuery *query = [JBQuery queryWithClassName:"Single"];
[query includeKey:@"album"];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjectsInBackgroundWithBlock:^(NSArray objects, NSError *error) {
    if (error) {
        
    } else {
        //返回的Single对象所关联的Album对象的属性值都已获取到
    }
}];
```
##3.8 原子操作
许多应用都需要实现计数器功能。比如一首单曲，我们需要记录有多少用户下载了它，但可能在同一时间内有多个用户对同一首单曲进行下载操作，如果在每个客户端直接把它们读到的计数值增加之后再写回去，那么极容易引发冲突和付费，导致结果不准，因此，我们使用`incrementKeyInBackground:block:`以原子操作方式来实现计数，这个方法默认计数加1：

```objc
//同步方法-默认计数加1
NSError *error = nil;
[single incrementKey:@"downloadCount" error:&error];

//异步方法-默认计数加1
[singel incrementKeyInBackground:@"downloadCount" block:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
        //返回成功，计数加1
    } else {
        //返回失败
    }
}];
```
也可以使用`incrementKeyInBackground:byAmount:block:`来给字段累加一个特定数值，传入的数值只能是整形的：
```objc
//同步方法-计数加任意值
NSError *error = nil;
[single incrementKeyInBackground:@"playCount" byAmount:@(10) error:&error];

//异步方法-计数加任意值
[single incrementKeyInBackground:@"playCount" byAmount:@(10) block:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
        //返回成功，计数加10
    } else {
        //返回失败
    }
}];
```
##3.9 批量操作
正在开发，敬请等待
##3.10 数据类型
目前，我们使用过的数据类型有`NSString`、`NSDate`、`NSNumber`、`NSArray`、`NSDictionary`和`JBObject`。
#四、查询
SDK中的`JBQuery`类提供了多种检索方法，以满足诸如单对象查询、多对象查询、缓存查询等多种需求。
##4.1 基本查询
单对象查询：`getObjectInBackgroundWithId:block:`，只能查询单个对象实例。

多对象查询：`findObjectsInBackgrounWithBlock:`，一般来说，在这之前需要创建一个`JBQuery`对象，并设定相应的查询条件，之后block会返回符合条件的由JBObject组成的NSArray.

例如，需要查找指定歌手（singer）的所有单曲，可以使用`whereKey:equalTo:`来设定查询条件。

```objc
//假定已知歌手名为"张三"的Singer对象"zhangsan"
JBQuery *query = [JBQuery queryWithClassName:@"Single"];
[query whereKey:@"singer" equalTo:zhangsan];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索单对象
[query findObjectsInBackgroudWithBlock:^(NSArray *objects, NSError) {
  if (error) {
    //查询失败，输出错误信息
  } else {
    //查询成功，返回singer为"张三"的所有Single对象
  }
}];
```
##4.2 约束查询
给`JBQuery`的查询添加约束条件有多种方法。
`whereKey:equalTo:`、`whereKey:notEqualTo:`用来搭配对应的键和值过滤对象。

```objc
//查询歌手不是张三的单曲
[query whereKey:@"singer" notEqualTo:@"张三"];
```
一次查询可以设置多个约束条件，只有满足所有约束条件的对象才会被返回，这相当于使用and类型的查询条件。

```objc
//查询歌手不是张三并且单曲时长超过180s的单曲
[query whereKey:@"singer" notEqualTo:@"张三"];
[query whereKey:@"length" greaterThan:@(180)];
```
`limit`：限制返回结果的数量。返回数量默认是100，limit取值范围是1到1000。

```objc
query.limit = 20; //最多返回20条结果
```
`skip`：跳过初始结果，对于分页很实用。

```objc
query.skip = 20; //跳过前20条查询结果
```

`addAscendingOrder`、`addDescendingOrder`：用来增加排序键。

```objc
//按照播放次数升序排列
[query addAscendingOrder:@"playTimes"];
//按照播放次数降序排列
[query addDescendingOrder:@"playTimes"];
```
查询中“比较”,`whereKey:lessThan:`(小于)、`whereKey:lessThanOrEqualTO:`(小于等于)、`whereKey:greaterThan:`(大于)、`whereKey:greaterThanOrEqualTo:`(大于等于)：

```objc
//下载次数 < 100
[query whereKey:@"downloadCount" lessThan:@(100)];
//下载次数 <= 100
[query whereKey:@"downloadCount" lessThanOrEqualTo:@(100)]
//下载次数 > 100
[query whereKey:@"downloadCount" greaterThan:@(100)];
//下载次数 >= 100
[query whereKey:@"downloadCount" greaterThanOrEqualTo:@(100)];
```
查询中的“存在”，`whereKeyExist:`(存在)、`whereDoesNotExist:`(不存在)：

```objc
//检索所有存在MV的单曲对象
JBQuery *query = [JBQuery queryWithClassName:@"Single"];
[query whereKeyExist:@"mv"];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjectsInBackgroudWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
        //返回错误，查询失败
    } else {
        //返回所有存在MV的单曲对象
    }
}];


//检索所有不存在MV的单曲对象
JBQury *query = [JBQuery queryWithClassName:@"Single"];
[query whereKeyDoesNotExist:@"mv"];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
        //返回错误，查询失败
    } else {
        //返回又说不含MV的单曲对象
    }
}];
```
##4.3 数组值查询
当属性值为数组时，可以使用`whereKey:containedIn:`

```objc
//假定已知歌手名为"张三"的zhangsan(Singer)对象和歌手名为"李四"的lisi(Singer)对象，检索出歌手为张三或李四的单曲对象
[query whereKey:@"singer" containedIn:@[zhangsan, lisi]];
```
##4.4 模糊查询

```objc
//查询所有名字name中包含“张”的歌手
JBQuery *query = [JBQuery queryWithClassName:@"Singer"];
[query whereKey:@"name" containsString:@"张"];
```
##4.5 关系查询
查询关系数据的方法有多种。可以使用`whereKey:equalTo:`，就像使用其他数据类型一样。

例如，每个单曲`Single`的`singer`字段都有一个`Singer`歌手对象，那么找出指定歌手的单曲：

```objc
// 假定已经获取到歌手名为“张三”的singer这个JBObject对象
JBQuery *query = [JBQuery queryWithClassName:"Single"];
[query whereKey:@"singer" equalTo:singer];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjctsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    // 返回的objects数组就是singer字段为张三所有Single对象
}];
```
如果要做嵌套查询，应使用`whereKey:matchesQuery:`，举例来说，检索专辑销量超过50000的所有单曲对象：

```objc
JBQuery *innerQuery = [JBQuery queryWithClassName:@"Album"];
[innerQuery whereKey:@"saleCount" greaterThan:@(50000)];
;
JBQuery *query = [JBQuery queryWithClassName:@"Single"];
[query whereKey:@"album" matchesQuery:innerQuery];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //objects包含了所有专辑销量超过50000的单曲对象
}];
```
如果要用一个对象中某一键值，去匹配另一个查询结果对象中一个键值，来得到最终结果，可以使用`whereKey:matchesKey:matchesClass:inQuery:`,例如，检索当前用户所关注歌手的所有单曲对象：

```objc
//获取当前用户关注的歌手列表
JBQuery *followQuery = [JBQuery queryWithClassName:@"FollowSinger"];
[followQuery whereKey:@"user" equalTo:[JBUser currentUser]];

JBQuery *singleQuery = [JBQuery queryWithClassName:@"Single"];
[singleQuery whereKey:@"singer" matchesKey:@"followSinger" matchesClass:@"Singer" inQuery:followQuery];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[singleQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
    if (error) {
        //返回错误，查询失败
    } else {
        //objects返回的就是当前用户所关注歌手的所有单曲对象
    }
}];
```
而如果是复合查询的话，可以使用`orQueryWithSubqueries:`.
例如，检索出下载次数很多或者下载次数很少的单曲：

```objc
JBQuery *lotsOfDownload = [JBQuery queryWithClassName:@"Single"];
[lotsOfDownload whereKey:@"downloadCount" greaterThan:@(1000)];
JBQuery *fewDownload = [JBQuery queryWithClassName:@"Single"];
[fewQuery whereKey:@"downloadCount" lessThan:@(10)];
JBQuery *query = [JBQuery orQueryWithSubqueries:[NSArray arrayWithObjects:lotsOfDownload, fewDownload, nil]];

//同步方法-检索多对象
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法-检索多对象
[query findObjectsInBackgroundWithBlock:^(NSArray *objectsm NSError *error) {
    if (error) {
        //返回错误，查询失败
    } else {
        //返回所有下载次数大于1000或小于10的单曲对象
    }
}];
```
注意：在复合查询的子查询中，不能使用非过滤性的约束(如limit、skip、includeKey:)等
##4.6 缓存查询
如果设备离线或者失去网络连接时，打开应用，希望数据也能显示出来，所以通常来说，将请求结果缓存到磁盘是最为简单有效的方法。

而默认的查询不会查询缓存数据，需要通过JBQuery的cachePolicy属性来设置。

例如，网络无法连接时，

```objc
JBQuery *query = [JBQuery queryWithClassName:@"Single"];
query.cachePolicy = JBCachePolicyCacheOnly;

//同步方法
NSError *error = nil;
NSArray *objects = (NSArray *)[query findObjects:&error];

//异步方法
[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
        //查询缓存失败，没有返回数据
    } else {
        //查询缓存成功，成功获取缓存数据
    }
}];
```

* JBCachePolicyDefault   
  默认，查询网络数据并更新缓存
* JBCachePolicyIgnoreCache  
  忽略缓存，查询不从缓存加载，也不将结果保存到缓存中
* JBCachePolicyCacheOnly   
  只查缓存，查询不从网络加载，只从缓存加载。
* JBCachePolicyCacheThenNetWork   
  先查缓存再查网络，查询先从缓存加载，如果失败，就加载网络数据。
* JBCachePolicyNetWorkOnly   
  只查网络，查询只查网络数据。


##4.7 计数查询
只需要获取查询结果的数量，而不需要获取具体的对象时，可以使用`countObject`和`countObjectsInBackgroundWithBlock`:方法。

例如，如果我们想知道某张专辑有多少首单曲的时候：

```objc
JBQuery *query = [JBQuery queryWithClassName:@"Album"];
[query whereKey:@"album" equalTo:@"李四的专辑"];

//同步方法-计数查询
NSError *error = nil;
NSInteger count = [query countObjects:&error];

//异步方法-计数查询
[query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
  if (error) {
    //返回错误
  } else {
    //返回查询结果的数量
  }
}];
```
#五、ACL权限控制
ACL(Access Control List)是数据安全管理办法，设置了访问修改权限，更好的保证用户数据安全，因此每一个表都有一个ACL列。

拥有读权限的User才能获取一个对象的数据，拥有写权限的User才能更改或删除一个对象。

默认情况下，每一个对象都是可读可写的。但当设置了ACL之后，默认的ACL就会被覆盖。

```objc
 JBACL *acl = [JBACL ACL];
 [acl setPublicReadAccess:YES];  //设置全部用户均可读
 [acl setPublicWriteAccess:YES];  //设置全部用户均可写
```
大部分时候，不同用户针对同一对象访问权限是不同的，那么就需要指定用户访问权限：

```objc
JBACL *acl = [JBACL ACL];
[acl setPublicReadAccess:YES];
[acl setWriteAccess:YES forUser:[JBUser currentUser]];
```
#六、文件JBFile
##6.1 JBFile
`JBFile`是继承自`JBObject`的子类。是用来处理文件管理所需功能的专门类。
`JBFile` 允许应用将文件存储到服务端，支持图片、视频等常见的文件类型，以及其他任何二进制数据。

```objc
NSData *data = [NSdata dataWithContentsOfURL:http://7xnus0.com2.z0.glb.qiniucdn.com/5645b2a574242e39eee89829/c25b2241637b49c8bc021a60abb5f23e];
JBFile *file = [JBFile fileWithName:@"video.mp4" data:data];
```
* 文件名允许重名，因为每一个JBFile对象都有唯一的objectId，所以即使重名也没问题。同样因为有objectId作为标识，文件也可以没有名字。
* 给文件添加拓展名十分必要，服务器通过拓展名判断文件类型，例如PNG图片的拓展名应该是.png，MP4视频文件的拓展名应该是.mp4，不应弄混弄错。

如果需要存储的文件是来自网上，可以使用JBFile提供的方法`fileWithURL:`，所以上面的代码也可以这么写：
```objc
JBFile *file = [JBFile fileWithURL:http://7xnus0.com2.z0.glb.qiniucdn.com/5645b2a574242e39eee89829/c25b2241637b49c8bc021a60abb5f23e];
```
##6.2 文件元数据
##6.3 视频类流媒体M3U8处理

##6.4 图像与缩略图获取（待定）
##6.5 进度提示
使用`saveInBackgroundWithBlock:progressBlock:`可以获取到`JBFile`的上传进度。例如：

```objc
[file saveInBackgroundWithBlock:^(id object, NSError *error) {
    //上传成功或失败的逻辑处理
} progressBlock:^(float percentDone) {
    //更新进度数据
}];
```
#七、用户JBUser
##7.1 JBUser
`JBUser`与`JBFile`一样都是`JBObject`的子类，是用来处理用户账户管理所需工能的专门用户类。它不光继承了`JBObject`所有的方法，具备同`JBObject`相同的功能，还增加扩展了一些特定的与用户账户相关的功能。
##7.2 特殊属性
`JBUser`除了继承自`JBObject`的属性外，还有一些特有属性：

* `username` : 用户的用户名（必需且唯一）
* `password` : 用户的密码（必需）
* `phone` : 用户用来注册的手机号码（可选）
* `email` : 用户用来注册的电子邮件地址（可选）
* `auth` : 用户授权第三方登录（可选）

##7.3 注册
大部分程序都会需要用户注册，例如：

```objc
JBUser *myUser = [JBUser user];
[user setObject:@"张三" forKey:@"username"];
[user setObject:@"123456" forKey:@"password"];

//同步方法-用户注册
NSError *error = nil;
[user signUp:&error];

//异步方法-用户注册
[user singUpInBackgroundWithBlock:^(id object, NSError *error) {
    if (error) {
        //注册失败
    } else {
        //注册成功
    }
}];
```
##7.4 登录（修改）
让已经成功注册的用户登录到自己的账户，可以调用`JBUser`类中登录相关的同异步方法，并根据用户选择登录方式的不同调用不同的方法。例如：

```objc
//同步方法-用户名、密码登录
NSError *error = nil;
[JBUser logInWithUsername:@"张三" password:@"123456" error:&error];

//异步方法-用户名、密码登录
[JBUser logInWithUsernameInBackground:@"张三" password:@"123456" block:^(id object, NSError *error) {
    if (error) {
        //登录失败
    } else {
        //登录成功
    }
}];

//第三方授权登录(目前支持的需要传入从第三方平台获取到的accessToken和uid， 并传入登录平台，如QQ、微信微博等)
//同步方法-第三方授权登录
NSError *error = nil;
[JBUser logInWithAuthData:{@"accessToken" : @"8343726DA09DB9830CC32486A4856E0A", @"uid" : @"638C29277C7538E555DFF0EF40BBADCD"} authType:JBPlatformQQ error:&error];

//异步方法-第三方授权登录
[JBUser logInWithAuthDataInBackground:{@"accessToken" : @"8343726DA09DB9830CC32486A4856E0A", @"uid" : @"638C29277C7538E555DFF0EF40BBADCD"} authType: JBPlatformQQ block:^(id object, NSError) {
    if (error) {
        //登录失败
    } else {
        //登录成功
    }
}];
```
目前支持的第三方平台有：

* JBPlatformSinaWeibo 使用微博账号登录
* JBPlatformQQ 使用QQ账号登录
* JBPlatformWeixin 使用微信账号登录


##7.5 当前用户
用户，是应用程序的核心。如果每次打开应用程序都要登录，会直接影响用户体验。为避免这种情况，可以使用缓存的`currentUser`对象。当用户成功注册或者第一次成功登录后，就将当前用户对象缓存在本地中，既方便下次调用，也给用户以最好的应用体验。

```objc
JBUser *current = [JBUser currentUser];
if (currentUser != nil) {
    //本地缓存用户对象不为空，当前用户已登录
} else {
    //本地缓存用户对象为空，当前用户未登录
}
```
清除缓存的用户对象：

```objc
[JBUser logout];  //清除本地缓存用户对象
JBUser *currentUser = [JBUser currentUser];  //现在currentUser是nil了
```
##7.6 修改/重置密码
当用户使用非第三方授权登录而是用户名密码或手机密码登录时，就会有更改密码的需求，我们也提供了相应的方法来满足用户的这一需求：

```objc
[JBUser logInWithUsernameInBackground:@"张三" password:@"123456" block:^(id object, NSError *error) {
    if (error) {
        //登录失败
    } else {
        //登录成功
    }
}];
//同步方法-重置密码
NSError *error = nil;
[[JBUser currentUser] updatePassword:@"123456" newPassword:@"000000" error:&error];

//异步方法-重置密码
[[JBUser currentUser] updatePassword:@"123456" newPassword:@"000000" block:^(id object, NSError *error) {
    if (error) {
        //返回错误，更改密码失败，可能是用户尚未登录、原密码错误或用户不存在等原因
    } else {
        //更改密码成功
    }
}];
```
##7.7 SessionToken介绍
`SessionToken`是`JBUser`的一个非常特殊的属性，是
`JBUser`的内建字段。当用户注册成功后，自动生成且唯一。

当用户更改重置密码后，`SessionToken`也会被重置。

`SessionToken`的作用主要有两个方面:

* 服务器用来校验用户登录与否
* 保证在多设备登录同一账号情况下，用户账号安全

#八、设备与推送
`JBInstallation`同样也是一个继承自`JBObject`的一个子类，是用来处理设备管理所需功能的专门类。

* `deviceToken` : 设备的唯一标示符
* `deviceType` : 对于iOS设备来说，type就是"iOS"


#九、调用云代码
可以使用JBCloud类的静态方法调用云代码中定义的函数：

```objc
[JBCloud callFunctionInBackgroud:@"functionName" withParameters:@{...} block:^(id object, NSError *error {
  //返回结果，业务逻辑
})];
```
functionName是云代码中函数的名称， parameters是传入的函数的参数，block对象作为调用结果的回调传入。

#十、其他
##10.1 调试模式
