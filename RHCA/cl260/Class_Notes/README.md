[toc]


## 1 介绍红帽 Ceph 存储架构

### 1.1 描述Ceph存储用户角色

Ceph 存储管理员一般执行下列任务：

1. 安装、配置和维护 Ceph 存储集群

2. 向基础架构师培训 Ceph 的功能和特性

3. 向用户介绍 Ceph 数据表示和方法，作为可选的数据应用选项

4. 提供弹性和恢复，例如复制、备份和灾难恢复方法

5. 通过基础架构即代码实现自动化和集成

6. 提供使用数据分析和高级大规模数据挖掘的权限



### 1.2 描述红帽 Ceph 存储架构

红帽 Ceph 存储提供企业级软件定义存储解决方案，它使用标准硬件和存储设备的服务器。Ceph 采用模块化分布式架构，包含下列元素：

1. 对象存储后端，称为 RADOS（Reliable Autonomic Distributed Object Store 可靠的自主分布式对象存储）

2. 与 RADOS 交互的多种访问方式

RADOS 是一种自我修复、自我管理的软件型对象存储



#### 1.2.1 Ceph 存储后端组件

RADOS 是 Ceph 存储后端，包含以下守护进程：

1. **MON (Monitor)** : 监控器
   维护集群状态映射。它们帮助其他守护进程互相协调

2. **OSD (Object Storage Devices)**: 对象存储设备
   存储数据并处理数据复制、恢复和重新平衡

3. **Managers (MGR)**: 管理器
   通过基于浏览器的仪表板和 REST API，跟踪运行时指标并公开集群信息

4. **MDS (Metadata Servers)**: 元数据服务器
   存储供 CephFS 使用的元数据（而非对象存储或块存储），让客户端能够高效执行 POSIX 命令

这些守护进程可以扩展，以满足部署的存储集群的要求

##### Ceph 监控器

Ceph 监控器 (MON) 是维护集群映射主要副本的守护进程，集群映射是由五种映射组成的集合，分别是：

1. 监视器映射

2. 管理器映射

3. OSD 映射

4. MDS 映射

5. CRUSH 映射

Ceph 必须处理每个集群事件，更新合适的映射，并将更新后的映射复制到每个监控器守护进程，若要应用更新，MON 必须就集群状态建立共识。这要求配置的监控器中有多数可用且就映射更新达成共识，为 Ceph 集群配置奇数个监控器，以确保监控器能在就集群状态投票时建立仲裁，配置的监控器中必须有超过半数正常发挥作用，Ceph 存储集群才能运行并可访问，这是保护集群数据的完整性所必需的

##### Ceph 对象存储设备

Ceph 对象存储设备 (OSD) 是 Ceph 存储集群的构建块，OSD 将存储设备（如硬盘或其他块设备）连接到 Ceph 存储集群。一台存储服务器可以运行多个 OSD 守护进程，并为集群提供多个 OSD，Ceph 旧版本要求 OSD 存储设备具有底层文件系统，但 BlueStore 以原始模式使用本地存储设备，这有助于提升性能

Ceph 客户端和 OSD 守护进程都使用可扩展哈希下的受控复制 (CRUSH, Controlled Replication Under Scalable Hashing) 算法来高效地计算对象位置的信息，而不依赖中央服务器查找

CRUSH 将每个对象分配给单个哈希存储桶，称为放置组 (PG)。PG  是对象（应用层）和 OSD（物理层）之间的抽象层，CRUSH 使用伪随机放置算法在 PG 之间分布对象，并且使用规则来确定 PG 到OSD 的映射。出现故障时，Ceph 将 PG 重新映射到不同的物理设备 (OSD) ，并同步其内容以匹配配置的数据保护规则，一个 OSD 是对象放置组的主要 OSD，Ceph 客户端在读取或写入数据时始终联系操作集合中的主要 OSD，其他 OSD 为次要 OSD，在确保集群故障时的数据弹性方面发挥重要作用

Primary OSD 的功能：

1. 服务所有 I/O 请求

2. 复制和保护数据

3. 检查数据的一致性

4. 重新平衡数据

5. 恢复数据

次要 OSD 的功能：

1. 行动始终受到 Primary OSD 的控制

2. 能够变为 Primary OSD

每个 OSD 具有自己的 OSD ⽇志。OSD 日志提供了对 OSD 实施写操作的性能。来自Ceph 客户端的写操作本质上通常是随机的 I/O，由 OSD 守护进程顺序写入到日志中。当涉及的所有OSD日志记录了写请求后，Ceph 将每个写操作确认到客户端，OSD 然后将操作提交到其后备存储。每隔几秒钟，OSD 会停止向日志写入新的请求，以将 OSD日志的内容应用到后备存储，然后，它会修剪日志中的已提交请求，回收日志存储设备上的空间

当 Ceph OSD 或其存储服务器出现故障时，Ceph 会在 OSD 重新启动后重演其日志，重演序列在最后一个已同步的操作后开始，因为 Ceph 已将同步的日志记录提交到 OSD 的存储，OSD日志使用OSD 节点上的原始卷，若有可能，应在单独的SSD等快速设备上配置日志存储

##### Ceph 管理器

Ceph 管理器 (MGR) 提供一系列集群统计数据，集群中不可用的管理器不会给客户端 I/O 操作带来负面影响。在这种情况下，尝试查询集群统计数据会失败，可以在不同的故障域中部署至少两个 Ceph 管理器提升可用性

管理器守护进程将集群中收集的所有数据的访问集中到一处，并通过 TCP 端⼝ 7000（默认）向存储管理员提供一个简单的 Web 仪表板。它还可以将状态信息导出到外部 Zabbix 服务器，将性能信息导出到 Prometheus。Ceph 指标是一种基于 collectd 和 grafana 的监控解决方案，可补充默认的仪表板

##### 元数据服务器

Ceph 元数据服务器（MDS）管理 Ceph 文件系统（CephFS）元数据。它提供兼容 POSIX 的共享文件系统元数据管理，包括所有权、时间戳和模式。MDS 使用 RADOS 而非本地存储来存储其元数据，它无法访问文件内容

MDS 可让 CephFS 与 Ceph 对象存储交互，将索引节点映射到对象，并在树内映射 Ceph 存储数据的位置，访问 CephFS 文件系统的客户端首先向 MDS 发出请求，这会提供必要的信息以便从正确的 OSD 获取文件内容

##### 集群映射

Ceph 客户端和对象存储守护进程 OSD 需要确认集群拓扑。五个映射表示集群拓扑，统称为集群映射。Ceph 监控器守护进程维护集群映射的主副本。Ceph MON 集群在监控器守护进程出现故障时确保高可用性

- **监控器映射** 包含集群 fsid、各个监控器的位置、名称、地址和端口，以及映射时间戳。使用 [ceph mon dump]() 来查看监控器映射。fsid 是一种自动生成的唯⼀标识符 (UUID)，用于标识 Ceph 集群

- **OSD 映射** 包含集群 fsid、池列表、副本大小、放置组编号、OSD 及其状态的列表，以及映射时间戳。使用 <a>ceph osd dump</a> 查看 OSD 映射 

- **放置组 (PG) 映射** 包含 PG 版本、全满比率、每个放置组的详细信息，例如 PG ID、就绪集合、操作集合、PG 状态、每个池的数据使用量统计、以及映射时间戳。使用[ceph pg dump]()查看包含的 PG 映射统计数据

- **CRUSH 映射** 包含存储设备的列表、故障域层次结构（例如设备、主机、机架、行、机房），以及存储数据时层次结构的规则，若要查看CRUSH 映射，首先使用[ceph osd getcrushmap -o comp-filename]()，使用[crushtool -d comp-filename -o decomp-filename]() 解译该输出，使用文本编辑器查看解译后的映射

- **元数据服务器 (MDS) 映射** 包含用于存储元数据的池、元数据服务器列表、元数据服务器状态和映射时间戳。查看包含 [ceph fs dump]() 的 MDS映射



#### 1.2.2 Ceph 访问方式

Ceph 提供四种访问 Ceph 集群的方法：

1. Ceph 原生 API (librados)

2. Ceph 块设备（RBD、librbd），也称为 RADOS 块设备 (RBD) 镜像

3. Ceph 对象网关

4. Ceph 文件系统（CephFS、libcephfs）

下图描述了Ceph集群的四种数据访问方法，支持访问方法的库，以及管理和存储数据的底层Ceph组件

<img src='https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/ceph-components.svg'>

##### Ceph 原生API (librados)

librados 是原生C 库，允许应用直接使用RADOS 来访问 Ceph 集群中存储的对象，有可以用C++、Java、Python、Ruby、Erlang 和 PHP，编写软件以直接与 librados 配合使用可以提升性能，为了简化对 Ceph 存储的访问，也可以改为使用提供的更高级访问方式，如 RADOS 块设备、Ceph 对象网关 (RADOSGW) 和 CephFS

##### RADOS 块设备

Ceph 块设备（RADOS 块设备或 RBD）通过 RBD 镜像在 Ceph 集群内提供块存储。Ceph 分散在集群不同的 OSD 中构成 RBD 镜像的个体对象。由于组成 RBD 的对象分布到不同的 OSD，对块设备的访问自动并行处理

RBD 提供下列功能：

1. Ceph 集群中虚拟磁盘的存储

2. Linux 内核中的挂载支持

3. QEMU、KVM 和 OpenStack Cinder 的启动支持

##### Ceph 对象网关（RADOS 网关）

Ceph 对象网关（RADOS 网关、RADOSGW 或 RGW）是使用librados 构建的对象存储接口。它使用这个库来与 Ceph 集群通信并且直接写入到 OSD 进程。它通过 RESTful API 为应⽤提供了网关，并且支持两种接口：Amazon S3 和 OpenStack Swift

Ceph 对象网关提供扩展支持，它不限制可部署的网关数量，而且支持标准的 HTTP 负载均衡器。它解决的这些案例包括：

1. 镜像存储（例如，SmugMug 和 Tumblr）

2. 备份服务

3. 文件存储和共享（例如，Dropbox）

##### Ceph 文件系统 (CephFS)

Ceph 文件系统 (CephFS) 是一种并行文件系统，提供可扩展的、单层级结构共享磁盘，Ceph 元数据服务器 (MDS) 管理与 CephFS 中存储的文件关联的元数据 ，这包括文件的访问、更改和修改时间戳等信息



#### 1.2.3 Ceph客户端组件

支持云计算的应用程序需要一个有异步通讯能力的简单对象存储接口，Ceph存储集群提供了这样的接口。客户端直接并行访问对象，包括:

1. 池操作

2. 快照

3. 读/写对象
   
   1. 创建或删除
   
   2. 整个对象或字节范围
   
   3. 追加或截断

4. 创建/设置/获取/删除 XATTRs

5. 创建/设置/获取/删除键/值对

6. 复合操作和 dual-ack 语义

当客户端写入RBD映像时，对象映射跟踪后端已存在的RADOS对象，当写入发生时，它会被转换为后端RADOS对象中的偏移量，当对象映射特性启用时，将跟踪RADOS对象的存在以表示对象存在，对象映射保存在librbd客户机的内存中，以避免在osd中查询不存在的对象

对象映射对于某些操作是有益的，例如:

1. 重新调整大小

2. 导出

3. 复制

4. 平衡

5. 删除

6. 读

存储设备有吞吐量限制，这会影响性能和可伸缩性。存储系统通常支持条带化，即跨多个存储设备存储连续的信息片段，以提高吞吐量和性能。当向集群写入数据时，Ceph客户端可以使用数据分条来提高性能



#### 1.2.4 Ceph 中的数据分布和整理

##### 使用池对存储进行分区

Ceph OSD 保护并持续检查集群中存储的数据的完整性，Pools 是 Ceph 存储集群的逻辑分区，用于将对象存储在共同的名称标签下。Ceph 给每个池分配特定数量的哈希存储桶，名为放置组 (PG)，将对象分组到一起进行存储。每个池具有下列可调整属性：

1. 不变 ID

2. 名称

3. 在 OSD 之间分布对象的 PG 数量

4. CRUSH 规则，用于确定这个池的 PG 映射

5. 保护类型（复制或纠删代码）

6. 与保护类型相关的参数

7. 影响集群行为的各种标志

分配给每个池的放置组数量可以独立配置，以匹配数据的类型以及池所需要的访问权限
CRUSH 算法用于确定托管池数据的OSD，每个池分配一条 CRUSH 规则作为其放置策略，CRUSH规则决定哪些 OSD 存储分配了该规则的所有池的数据

##### 放置组

放置组 (PG) 将一系列对象聚合到一个哈希存储桶或组中。Ceph 将每个 PG 映射到一组 OSD。一个对象属于一个 PG，但属于同一PG 的所有对象返回相同的散列结果

CRUSH 算法根据对象名称的散列，将对象映射至其 PG。这种放置策略也被称为 CRUSH 放置规则，放置规则标识在 CRUSH 拓扑中选定的故障域，以接收各个副本或纠删码区块

当客户端将对象写入到池时，它使用池的 CRUSH 放置规则来确定对象的放置组。客户端然后使用其集群映射的副本、放置组以及 CRUSH 放置规则来计算对象的副本（或其纠删码区块）应写入到哪些 OSD 中

当新的 OSD 可供 Ceph 集群使用时，放置组提供的间接层非常重要。在集群中添加或移除 OSD 时，放置组会自动在正常运作的 OSD 之间重新平衡

##### 将对象映射到其关联的 OSD

1. Ceph 客户端从监控器获取集群映射的最新副本。集群映射向客户端提供有关集群中所有MON、OSD 和 MDS 的信息。它不会向客户端提供对象的位置，客户端必须使用CRUSH 来计算它需要访问的对象位置

2. 要为对象计算放置组 ID，Ceph 客户端需要对象 ID 以及对象的存储池名称。客户端计算 PG ID，这是对象 ID 模数哈希的 PG 数量。接着，它根据池名称查找池的数字 ID，再将池 ID 作为前缀添加到PG ID 中

3. 然后，使用CRUSH 算法确定哪些 OSD 负责某一个 PG（操作集合）。操作集合中目前就绪的 OSD位于就绪集合中，就绪集合中的第一个 OSD 是对象放置组的当前主要 OSD，就绪集合中的所有其他OSD 为次要 OSD

4. Ceph 客户端然后可以直接与主要 OSD 交互，以访问对象

##### 数据保护

和 Ceph 客⼾端一样，OSD 守护进程使用CRUSH 算法，但 OSD 守护进程使用它来计算对象副本的存储位置以及用于重新平衡存储。在典型的写入场景中，Ceph 客户端使用CRUSH 算法计算原始对象的存储位置，将对象映射到池和放置组，然后使用CRUSH 映射来确定映射的放置组的主要OSD。在创建池时，将它们设置为复制或纠删代码池

<img title="" src="https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/ceph-pool-protection.svg" alt="" width="914">

为了提高弹性，为池配置在出现故障时不会丢失数据的 OSD 数量。对于复制池（默认的池类型），该数量决定了在不同设备之间创建和分布对象的副本数。复制池以较低的可用存储与原始存储比为代价，在所有用例中提供更佳的性能

纠删代码提供了更经济高效的数据存储方式，但性能更低。对于纠删代码池，配置值确定要创建的编码块和奇偶校验块的数量

纠删代码的主要优势是能够提供极高的弹性和持久性。还可以配置要使用的编码区块（奇偶校验）数量，RADOS 网关和 RBD 访问方法都支持纠删代码

下图演示了如何在Ceph集群中存储数据对象。Ceph 将池中的一个或多个对象映射到一个 PG，由彩色框表示。此图上的每一个 PG 都被复制并存储在 Ceph 集群的独立 OSD 上

<img title="" src="https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/crush-placement-groups.svg" alt="" width="689" data-align="inline">



### 1.3 描述Ceph存储管理接口

#### 1.3.1 介绍Ceph接口

以前的Ceph版本使用Ceph-ansible软件中的Ansible Playbooks进行部署并管理集群，Red Hat Ceph Storage 5引入了cephadm作为工具来管理集群的整个生命周期(部署、管理和监控)，替换之前的ceph-ansible提供的功能

Cephadm被视为Manager守护进程(MGR)中的一个模块，这是部署新集群时的第一个守护进程，Ceph集群核心集成了所有的管理任务

Cephadm由Cephadm包装提供，应该在第一个集群节点上安装这个包，它充当引导节点。Ceph 5被部署在容器中，建立并运行Ceph集群的仅有几个安装包要求是cephadm、podman、python3、chrony，容器化版本降低了部署过程中的复杂性和包依赖关系

下图说明了Cephadm如何与其他服务交互

![cephadm](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/cephadm.svg)

Cephadm可以登录到容器注册中心来提取Ceph映像，并使用该映像在节点上部署服务。当引导集群时，这个Ceph容器映像是必需的，因为部署的Ceph容器是基于该映像，为了与Ceph集群节点交互，Cephadm使用SSH连接向集群添加新主机、添加存储或监控这些主机



#### 1.3.2 探索Ceph管理接口

Ceph部署在容器中，在引导节点中不需要额外的软件，可以从集群的引导节点中的命令行引导集群，引导集群设置了一个最小的集群配置，其中只有一个主机(引导节点)和两个守护进程(监视器和管理进程)，Red Hat Ceph Storage 5提供两个默认部署的接口: Ceph CLI 和 Dashboard GUI



#### 1.3.3 Ceph编排器

可以使用Ceph编排器轻松地向集群添加主机和守护进程，使用编排器来提供Ceph守护进程和服务，并扩展或收缩集群。通过Ceph orch命令使用Ceph编排器，还可以使用Red Hat Ceph Storage Dashboard接口来运行编排器任务。cephadm脚本与Ceph Manager业务流程模块交互

下面的图表说明了Ceph Orchestrator

![Orchestrator](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/cephorch.svg)

##### Ceph命令行接口

Cephadm可以启动一个装有所有必需Ceph包的容器，使用这个容器的命令是cephadm shell，只应该在引导节点中运行此命令，因为在引导集群时，只有这个节点可以访问/etc/ceph中的admin密钥

```bash
[root@clienta ~]# cephadm shell
Inferring fsid 2ae6d05a-229a-11ec-925e-52540000fa0c
Inferring config /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.clienta/config
Using recent ceph image registry.redhat.io/rhceph/rhceph-5-rhel8@sha256:6306de945a6c940439ab584aba9b622f2aa6222947d3d4cde75a4b82649a47ff
[ceph: root@clienta /]# 
```

可以通过破折号直接非交互式执行命令

```bash
[root@clienta ~]# cephadm shell -- ceph -s
Inferring fsid 2ae6d05a-229a-11ec-925e-52540000fa0c
Inferring config /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.clienta/config
Using recent ceph image registry.redhat.io/rhceph/rhceph-5-rhel8@sha256:6306de945a6c940439ab584aba9b622f2aa6222947d3d4cde75a4b82649a47ff
  cluster:
    id:     2ae6d05a-229a-11ec-925e-52540000fa0c
    health: HEALTH_OK
```

##### Ceph Dashboard接口

Red Hat Ceph Storage 5 Dashboard GUI通过该接口增强了对许多集群任务的支持，Ceph Dashboard GUI是一个基于web的应用程序，用于监控和管理集群，它以比Ceph CLI更直观的方式提供了集群信息。与Ceph CLI一样，Ceph将Dashboard GUI web服务器作为Ceph -mgr守护进程的一个模块，默认情况下，当创建集群时，Ceph在引导节点中部署Dashboard GUI并使用TCP端口8443

Ceph Dashboard GUI提供了这些特性：

- **多用户和角色管理**：可以创建具有多种权限和角色的不同用户帐户

- **单点登录**：Dashboard GUI允许通过外部身份提供者进行身份验证

- **审计**：可以配置仪表板来记录所有REST API请求

- **安全**：Dashboard默认使用SSL/TLS保护所有HTTP连接

Ceph Dashboard GUI还实现了管理和监控集群的不同功能，下面的列表虽然不是详尽的，但总结了重要的管理和监控特点:

##### 管理功能

1. 使用 CRUSH map 查看集群层次结构

2. 启用、编辑和禁用管理器模块

3. 创建、移除和管理osd

4. 管理iSCSI

5. 管理池

##### 监控功能

1. 检查整体集群健康状况

2. 查看集群中的主机及其服务

3. 查看日志

4. 查看集群警报

5. 检查集群容量

下图显示了Dashboard GUI中的状态屏幕。可以快速查看集群的一些重要参数，如集群状态、集群中的主机数量、osd数量等

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/gui-dashboard-status.png)



## 2. 部署红帽 Ceph 存储集群

### 2.1 部署红帽 Ceph 存储

#### 2.1.1 准备集群部署

本次采用cephadm工具来进行部署，cephadm会包含两个组件

1. cephadm shell

2. cephadm orchestrator

cephadm shell命令在ceph提供的管理容器中运行一个bash shell，最初使用cephadm shell执行集群部署任务、安装并运行集群后执行集群管理任务。

启动cephadm shell以交互方式运行单个或多个命令，要以交互方式运行它，应使用cephadm shell命令打开shell，然后运行Ceph命令。

cephadm 提供了一个命令行来编排ceph-mgr模块，该模块与外部编排服务进行对接，编排器的作用是协调必须跨多个节点和服务协作进行配置更改

```bash
[root@clienta ~]# cephadm shell
Inferring fsid 2ae6d05a-229a-11ec-925e-52540000fa0c
Inferring config /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.clienta/config
Using recent ceph image registry.redhat.io/rhceph/rhceph-5-rhel8@sha256:6306de945a6c940439ab584aba9b622f2aa6222947d3d4cde75a4b82649a47ff
[ceph: root@clienta /]# 
```

如果要执行非交互式的单个命令，可以用两个破折号连接

```bash
[root@clienta ~]# cephadm shell -- ceph osd pool ls
Inferring fsid 2ae6d05a-229a-11ec-925e-52540000fa0c
Inferring config /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.clienta/config
Using recent ceph image registry.redhat.io/rhceph/rhceph-5-rhel8@sha256:6306de945a6c940439ab584aba9b622f2aa6222947d3d4cde75a4b82649a47ff
device_health_metrics
.rgw.root
default.rgw.log
default.rgw.control
default.rgw.meta
```

##### 规划服务托管

所有集群服务现在都作为容器运行。容器化的Ceph服务可以运行在同一个节点上;这叫做“托管”。Ceph服务的托管允许更好地利用资源，同时保持服务之间的安全隔离。支持与OSD配置的守护进程有:RADOSGW、MOS、RBD-mirror、MON、MGR、Grafana、NFS Ganesha

##### 节点之间的安全通讯

cephadm命令使用SSH协议与存储集群节点通信。集群SSH Key是在集群引导过程中创建的。将集群公钥复制到每个主机，使用如下命令复制集群密钥到集群节点:

```bash
[root@node -]# cephadm shell 
[ceph: root@node /]# ceph cephadm get-pub-key > ~/ceph.pub 
[ceph: root@node /]# ssh-copy-id -f -i ~/ceph.pub root@node.example.com
```



#### 2.1.2 部署新集群

部署新集群的步骤如下：

1. 在选择作为引导节点的主机上安装cephadm-ansible包，它是集群中的第一个节点。

2. 在节点上执行cephadm的预检查playbook。该剧本验证主机是否具有所需的先决条件。

3. 使用cephadm引导集群。引导过程完成以下任务:
   
   1. 在引导节点上安装并启动Ceph Monitor和Ceph Manager守护进程
   
   2. 创建/etc/ceph目录
   
   3. 拷贝一份集群SSH公钥到"/etc/ceph/ceph"，并添加密钥到/root/.ssh/authorized_keys文件中
   
   4. 将与新集群通信所需的最小配置文件写入/etc/ceph/ceph.conf文件
   
   5. 写入client.admin管理密钥到/etc/ceph/ceph.client.admin.keyring
   
   6. 为prometheus和grafana服务以及其他工具部署一个基本的监控stack

##### 安装先决条件

在引导节点上安装cephadm-ansible

```bash
[root@node ~]# yum install cephadm-ansible
```

运行cephadm-preflight，这个剧本配置Ceph存储库并为引导准备存储集群。它还安装必要的包，例如Podman、lvm2、chrony和cephaldm

cephadm-preflight使用cephadm-ansible inventory文件来识别admin和client节点

inventory默认位置是/usr/share/cephadm-ansible/hosts，下面的例子展示了一个典型的inventory文件的结构:

```ini
[admin]
node00

[clients]
client01
client02
client03
```

运行cephadm-preflight

```bash
[root@node ~]# ansible-playbook \
	-i INVENTORY-FILE \
	-e "ceph_origin=rhcs" \
	cephadm-preflight.yml
```

##### bootstrap 引导集群

cephadm引导过程在单个节点上创建一个小型存储集群，包括一个Ceph Monitor和一个Ceph Manager，以及任何必需的依赖项

通过使用ceph orchestrator命令或Dashboard GUI扩展存储集群添加集群节点和服务

###### 使用cephadm bootstrap引导新集群

```bash
*[root@node -]# cephadm bootstrap \
  --mon-ip=MON_IP \
  --allow-fqdn-hostname
  --initial-dashboard-password=DASHBOARO_PASSWORO \
  --dashboard-password-noupdate \
  --registry-url=registry.redhat.io \
  --registry-username=REGISTRY_USERNAME \
  --registry-password=REGISTRY_PASSWORD
```

运行结束后，会输出以下内容

```bash
Ceph Dashboard is now available at: 
URL: https://boostrapnode.example.com:8443/ 
User: admin 
Password: adminpassword 
You can access the Ceph CLI with: 
sudo /usr/sbin/cephadm shell --fsid 266ee7a8-2a05-lleb-b846-5254002d4916 -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring 
Please consider enabling telemetry to help improve Ceph: 
ceph telemetry on
```

##### 使用服务规范文件

cephadm bootstrap命令使用--apply-spec选项和服务规范文件用于引导存储集群并配置其他主机和守护进程，配置文件是一个YAML文件，其中包含服务类型、位置和要部署服务的指定节点

服务配置文件示例如下:

```yaml
service_type: host
addr: node-00
hostname: node-00
---
service_type: host
addr: node-01
hostname: node-01
---
service_type: host
addr: node-02
hostname: node-02
---
service_type: mon
placement:
  hosts:
    - node-00
    - node-01
    - node-02
---
service_type: mgr
placement:
  hosts:
    - node-00
    - node-01
    - node-02
---
service_type: rgw
service_id: realm.zone
placement:
  hosts:
    - node-01
    - node-02
---
service_type: osd
placement:
  host_pattern: "*"
data_devices:
  all:true
```

```bash
[root@node ~]# cephadm bootstrap \
	--mon-ip MONITOR-IP-ADDRESS \
	--apply-spec CONFIGURATION_FILE_NAME 
```



#### 2.1.3 为集群节点打标签

Ceph协调器支持为主机分配标签，标签可以用于对集群进行分组hosts，以便可以同时将Ceph服务部署到多个主机，主机可以有多个标签

标签可以帮助识别每个主机上运行的守护进程，从而简化集群管理任务，例如，您可以使用ceph orch host ls或YAML服务规范文件在特定标记的主机上部署或删除守护进程，可以使用ceph orch host ls命令来列出我们可以用于编排器或YAML服务规范文件，在指定的标签节点上用于部署或删除特定的守护进程

除了 `_admin` 标签外，标签都是自由形式，没有特定的含义，可以使用标签，如mon, monitor, mycluster_monitor，或其他文本字符串标签和分组集群节点。例如，将mon标签分配给部署mon守护进程的节点，为部署mgr守护进程的节点分配mgr标签，并为RADOS分配rgw网关

例如，下面的命令将_ admin标签应用到主机，以指定为admin节点

```bash
*[ceph: root@node /)# ceph orch \
	host label add AOMIN_NOOE _admin
```

使用标签将集群守护进程部署到特定的主机

```bash
(ceph: root@node /)# ceph orch \
	apply prometheus --placement="label:prometheus"
```



#### 2.1.4 设置Admin节点

配置admin节点的步骤如下:

1. 将admin标签分配给节点

2. 复制admin密钥到管理节点

3. 复制ceph.conf文件到admin节点

```bash
[root@node ~]# scp \
	/etc/ceph/ceph.client.admin.keyring ADMIN_NODE:/etc/ceph/ 
[root@node ~]# scp \
	/etc/ceph/ceph.conf ADMIN_NODE:/etc/ceph/
```



### 2.2 执行Ceph存储集群扩容

有两种方法可以扩展集群中的存储空间:

1. 向集群中添加额外的OSD节点，这称为横向扩展

2. 向以前的OSD节点添加额外的存储空间，这称为纵向扩展

在开始部署额外的osd之前使用cephadm shell -- ceph health命令确保集群处于HEALTH_OK状态



#### 2.2.1 配置更多的OSD服务器

作为存储管理员，可以向Ceph存储集群添加更多主机，以维护集群健康并提供足够的负载容量。在当前存储空间已满的情况下，可以通过增加一个或多个osd来增加集群存储容量。

##### 分发ssh密钥

作为root用户，将Ceph存储集群SSH公钥添加到新主机上root用户的authorized_keys文件中

```bash
[root@adm ~]# ssh-copy-id \
	-f -i /etc/ceph/ceph.pub \
	root@new-osd-1
```

##### 检查并配置先决条件

作为root用户，将新节点添加到目录/usr/share/cephadm-ansible/hosts/的inventory文件中，使用--limit选项运行preflight剧本，以限制剧本的任务只在指定的节点上运行，Ansible Playbook会验证待添加的节点是否满足前置要求

```bash
[root@adm ~]# ansible-playbook \
	-i /usr/share/cephadm-ansible/hosts/ \
	--limit new-osd-1 \
	/usr/share/cephadm-ansible/cephadm-preflight.yml
```

##### 选择添加主机的方法

##### 使用命令

以root用户，在Cephadm shell下，使用ceph orch host add命令添加一个存储集群的新主机，在本例中，该命令还分配主机标签

```bash
*[ceph: root@adm /]# ceph orch \
	host add new-osd-1 --labels=mon,osd,mgr
```

##### 使用规范文件添加多个主机

要添加多个主机，创建一个包含主机描述的YAML文件，在管理容器中创建YAML文件，然后运行ceph orch

```yaml
service_type: host
addr:
hostname: new-osd-1
labels:
  - mon
  - osd
  - mgr
---
service_type: host
addr:
hostname: new-osd-2
labels:
  - mon
  - osd
```

使用ceph orch apply添加OSD服务器

```bash
[ceph: root@adm ~]# ceph orch apply -i host.yaml
```



#### 2.2.2 列出主机

ceph orch host ls可以列出所有主机，正常情况下STATUS是空的

```bash
[ceph: root@clienta ~]# ceph orch host ls 
HOST                     ADDR           LABELS  STATUS  
clienta.lab.example.com  172.25.250.10  _admin          
serverc.lab.example.com  172.25.250.12                  
serverd.lab.example.com  172.25.250.13                  
servere.lab.example.com  172.25.250.14                  
```



#### 2.2.3 为OSD服务器配置额外的OSD存储

Ceph要求在考虑存储设备时需满足以下条件:

1. 设备不能有任何分区

2. 设备不能有LVM

3. 设备不能被挂载

4. 该设备不能包含文件系统

5. 设备不能包含Ceph BlueStore OSD

6. 设备大小必须大于5GB

ceph orch device ls可以列出集群中可用的osd，--wide选项可以查看更多详情

```bash
[ceph: root@clienta ~]#  ceph orch device ls --wide
Hostname                 Path      Type  Transport  RPM      Vendor  Model  Serial  Size   Health   Ident  Fault  Available  Reject Reasons                                                 
clienta.lab.example.com  /dev/vdb  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
clienta.lab.example.com  /dev/vdc  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
clienta.lab.example.com  /dev/vdd  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
clienta.lab.example.com  /dev/vde  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
clienta.lab.example.com  /dev/vdf  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
serverc.lab.example.com  /dev/vde  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
serverc.lab.example.com  /dev/vdf  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
serverc.lab.example.com  /dev/vdb  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
serverc.lab.example.com  /dev/vdc  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
serverc.lab.example.com  /dev/vdd  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
serverd.lab.example.com  /dev/vde  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
serverd.lab.example.com  /dev/vdf  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
serverd.lab.example.com  /dev/vdb  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
serverd.lab.example.com  /dev/vdc  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
serverd.lab.example.com  /dev/vdd  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
servere.lab.example.com  /dev/vde  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
servere.lab.example.com  /dev/vdf  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    Yes                                                                       
servere.lab.example.com  /dev/vdb  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
servere.lab.example.com  /dev/vdc  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
servere.lab.example.com  /dev/vdd  hdd   Unknown    Unknown  0x1af4  N/A            10.7G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
[ceph: root@clienta ~]# 
```

以root用户执行ceph orch daemon add osd命令，在指定主机上使用指定设备创建osd

```bash
[ceph: root@admin /]# ceph orch \
	daemon add osd osd-1:/dev/vdb 
```

执行ceph orch apply osd --all-available-devices命令，在所有可用且未使用的设备上部署osd

```bash
[ceph: root@adm /]# ceph orch \
	apply osd --all-available-devices
```

可以仅使用特定主机上的特定设备创建osd，下例中，在每台主机上由default_drive_group组中提供的后端设备/dev/vdc和/dev/vdd创建两个osd

```yaml
[ceph: root@adm I]# cat lvarlliblcephlosdlosd_spec.yml 
service_type: osd
service_id: default_drive_group
placement:
  hosts:
    - osd-1
    - osd-2
data_devices:
  paths:
    - /dev/vdc
    - /dev/vdd
```

执行ceph orch apply命令实现YAML文件中的配置

```bash
[ceph: root@adm /]# ceph orch \
	apply -i /var/lib/ceph/osd/osd_spec.yml
```



## 3. 配置红帽 Ceph 存储集群

### 3.1 管理集群配置

#### 3.1.1 Ceph集群配置简介

所有的Ceph存储集群配置包含这些必需的定义:

1. 集群网络配置

2. 集群监视器(MON)配置和引导程序选项

3. 集群身份验证配置

4. 守护进程的配置选项

Ceph配置设置使用唯一的名称，该名称由小写字母与下划线连接

每个Ceph守护进程、进程和库都从以下来源访问它的配置:

1. 编译后的默认值

2. 集中式配置数据库

3. 保存在本地主机上的配置文件

4. 环境变量

5. 命令行参数

6. 运行时将覆盖

监视器(MON)节点管理集中的配置数据库，在启动时，Ceph守护进程通过命令行选项解析环境变量和本地集群配置文件提供的配置选项，守护进程然后联系MON集群以检索存储在集中配置数据库中的配置设置。Red Hat Ceph Storage 5已降级/etc/ceph/ceph.conf配置文件，使集中配置数据库成为存储配置设置的首选方式



#### 3.1.2 修改集群配置文件

每个Ceph节点存储一个本地集群配置文件，集群配置文件的默认位置为/etc/ceph/ceph.conf，cephadm工具使用最小的选项集创建一个初始的Ceph配置文件

配置文件使用一种INI文件格式，包含几个部分，其中包括对Ceph守护进程和client的配置，每个section都有一个名称，它是用[name]头定义的，以及定义为键值对的一个或多个参数

```ini
[name] 
parameterl = valuel
parameter2 = value2 
```

使用井号#分号;来禁用设置或添加注释，设置引导集群时使用集群配置文件以及自定义设置，使用cephadm boostrap带有--config选项的命令来传递配置文件

```bash
[root@node ~]# cephadm bootstrap --config ceph-config.yaml
```



##### 配置Sections

Ceph将配置设置组织到组中，无论是存储在配置文件中还是存储在配置数据库，使用sections调用它们应用到的守护进程或客户端

1. [global]存储所有守护进程或读取配置的任何进程(包括客户端)通用的通用配置，可以通过为各个守护进程或客户端创建被调用的部分来覆盖[global]参数

2. [mon]存储了监视器(mon)的配置

3. [osd]存储osd守护进程的配置

4. [mgr]存储Managers (mgr)的配置

5. [mds]存储元数据服务器(mds)的配置

6. [client]存储了应用于所有Ceph客户端的配置



##### 实例设置

将应用于特定守护进程实例的设置分组在各自的部分中，名称为[daemon-type.instance- id]

```ini
[mon]
# Settings for all mon daemons

[mon.serverc]
# Settings that apply to the specific MON daemon running on serverc
```

同样的命名也适用于[osd]， [mgr]， [mds]和[client]段。对于OSD进程，实例ID总是为数字，例如[osd.0]，对于客户端，实例ID为活动用户名，例如[client.operator3]



##### 元变量

元变量是ceph定义的变量。使用它们可以简化配置

==$cluster==：Red Hat Ceph Storage 5集群名称，默认集群名称为ceph

==$type==：守护进程类型，例如monitor使用mon，OSDs使用osd、MDSes使用mds, MGRs使用mgr，client应用程序使用client

==$id==：守护进程实例ID，在serverc上的monitor变量的值为的serverc，osd 1的id是osd.1，client应用程序是用户名

==$name==：守护进程名称和实例ID，这个变量是==$type.$id==的快捷方式

==$host==：运行守护进程的主机名



#### 3.1.3 使用集中式配置数据库

MON集群在MON节点上管理和存储集中配置数据库，可以临时更改设置(直到守护进程重新启动)，也可以配置设置永久保存并存储在数据库中，可以在集群运行时更改大多数配置设置

使用ceph config命令查询数据库，查看配置信息

[ceph config ls]() 列出所有可能的配置设置

[ceph config help setting]()查询特定的配置设置的帮助

[ceph config dump]()显示集群配置数据库设置

[ceph config show $type.$id]()显示特定守护进程的数据库设置。使用show-with -defaults包含默认设置

[ceph config get $type.$id]()，以获得特定的配置设置

[ceph config set $type.$id]()，用于设置特定的配置设置



```bash
[ceph: root@node /]# ceph config assimilate-conf -i ceph.conf
```



#### 3.1.4 集群引导选项

一些选项提供启动集群所需的信息。MON节点通过读取monmap来找到其他的MON并建立quorum。MON节点读取ceph.conf文件来确定如何与其他MONs进行通信

mon_host选项列出集群监视器，此选项非常重要，不能存储在配置数据库中，为了避免使用集群配置文件，Ceph集群支持使用DNS服务记录来提供mon_host列表

本地集群配置文件可以包含其他选项以满足的需求：

1. mon_host_override，集群要联系以开始通信的初始监视器列表

2. mon_dns_serv_name, 要检查的DNS SRV记录的名称，以便通过DNS识别集群监视器

3. mon_data, osd_data, mds_data, mgr_data，定义守护进程的本地数据存储目录

4. Keyring，keyfile和key，它们是要用监视器进行身份验证的身份验证凭证



#### 3.1.5 使用服务配置文件

服务配置文件是引导存储集群和其他Ceph服务的YAML文件。cephadm工具通过平衡集群中运行的守护进程来协调服务部署、大小和放置，通过各种参数，可以更明确地部署osd、mon等服务

下面是一个服务配置文件示例：

```yaml
service_type: mon
placement:
  host_pattern: "mon"
  count: 3 
---
service_type: osd 
service_id: default_drive_group 
placement: 
  host_pattern: "osd*" 
data_devices: 
  all: true
```

1. Service_type定义了服务的类型，如mon、mds、mgr、rgw等

2. 位置定义要部署的服务的位置和数量，可以定义主机、主机模式或标签来选择目标服务器

3. data_devices是特定于OSD服务的，支持的过滤参数为大小、模型或路径等

使用cephadm bootstrap - -apply- spec命令应用指定文件中的服务配置

```bash
[root@node ~]# cephadm bootstrap \
	--apply-spec service-config.yaml 
```



#### 3.1.6 在运行时覆盖配置设置

可以在运行时更改大多数集群配置设置，可以在守护进程运行时临时更改配置设置

[ceph tell $type.$id config]() 命令临时覆盖配置设置，并且要求所配置的MONs和守护进程都在运行，在任何配置为运行ceph命令的集群主机上运行此命令，使用该命令更改的设置在守护进程重新启动时恢复到原来的设置

[ceph tell $type.$id config get]() 获取守护进程的特定运行时设置

[ceph tell $type.$id config set]() 设置守护进程的特定运行时设置，当守护进程重新启动时，这些临时设置会恢复到原来的值

[ceph tell $type.$id config]() 命令还可以接受通配符来获取或设置同一类型的所有守护进程的值。例如[ceph tell osd.* config get debug_ms]() 显示集群中所有OSD守护进程的该设置的值

可以使用[ceph daemon $type.$id config]() 临时覆盖配置设置，在需要设置的集群节点上运行此命令

ceph daemon不需要通过MONs进行连接，即使在MONs不运行的情况下，ceph daemon命令仍然可以运行，这对于故障排除很有用

[ceph daemon $type.$id config get]() 获取守护进程的特定运行时设置

[ceph daemon $type.$id config set]() 设置守护进程的特定运行时设置，当守护进程重新启动时，临时设置会恢复到原来的值



### 3.2 配置集群监控

#### 3.2.1 Ceph监控配置

Ceph监视器(MONs)存储和维护客户端用来查找MON和OSD节点的集群映射，Ceph客户端在向osd读写任何数据之前，必须连接到一个MON来检索集群映射，因此，正确配置集群MONs至关重要，MONs通过使用一种变异的Paxos算法组成一个quorum，选出一个leader，在一组分布式计算机之间达成共识，MONs有以下角色之一：

1. Leader：第一个获得最新版本的cluster map的MON

2. Provider：一个MON，它具有集群映射的最新版本，但不是leader

3. Requester：一个MON，它没有最新版本的集群映射，并且在重新加入仲裁之前必须与Provider同步

同步总是在新的MON加入集群时发生，每个MON定期检查相邻的监视器是否有最新版本的集群映射，如果一个MON没有集群映射的最新版本，那么它必须同步并获取它

要建立仲裁，集群中的大多数MONs必须处于运行状态，例如，如果部署了5个MONs，那么必须运行3个MONs来建立仲裁，在生产Ceph集群中部署至少三个MON节点，以确保高可用性，支持对运行中的集群添加或移除mon，集群配置文件定义了用于集群操作的MON主机IP地址和端口，rnon_host设置可以包含IP地址或DNS名称，cephadm工具无法更新集群配置文件，定义一个策略来保持集群配置文件在集群节点之间同步，例如使用rsync

```ini
[global]
mon_host = [v2:172.25.250.12:3300,v1:172.25.250.12:6789], [v2:172.25.250.13:3300,v1:172.25.250.13:6789], [v2:172.25.250.14:3300, v1:172.25.250.14:6789] 
```

不建议在集群部署并运行后修改MON节点IP地址

#### 3.2.2 查看Monitor仲裁

使用ceph status或ceph mon stat命令验证MON仲裁状态

```bash
[ceph: root@clienta /]#  ceph mon stat
e4: 4 mons at {clienta=[v2:172.25.250.10:3300/0,v1:172.25.250.10:6789/0],serverc.lab.example.com=[v2:172.25.250.12:3300/0,v1:172.25.250.12:6789/0],serverd=[v2:172.25.250.13:3300/0,v1:172.25.250.13:6789/0],servere=[v2:172.25.250.14:3300/0,v1:172.25.250.14:6789/0]}, election epoch 134, leader 0 serverc.lab.example.com, quorum 0,1,2,3 serverc.lab.example.com,clienta,serverd,servere
```

或者，使用ceph quorum_status命令。添加-f json-pretty选项以创建更可读的输出

```json
[ceph: root@clienta /]# ceph quorum_status -f json-pretty

{
    "election_epoch": 134,
    "quorum": [
        0,
        1,
        2,
        3
    ],
    "quorum_names": [
        "serverc.lab.example.com",
        "clienta",
        "serverd",
        "servere"
    ],
    "quorum_leader_name": "serverc.lab.example.com",
```

也可以在“Dashboard”中查看MONs的状态。在仪表板中，单击Cluster-->Monitors，查看Monitor节点和仲裁的状态



#### 3.2.3 分析mon map

Ceph集群地图包括MON map、OSD map、PG map、MDS map和CRUSH map

MON映射包含集群fsid(文件系统ID)，以及与每个MON节点通信的名称、IP地址和网口。fsid是一个惟一的、自动生成的标识符(UUID)，用于标识Ceph集群

MON映射还保存映射版本信息，例如最后一次更改的序号(epoch )和时间，MON节点通过同步更改和对当前版本达成一致来维护映射

使用ceph mon dump命令查看当前的mon映射。

```bash
[ceph: root@clienta /]# ceph mon dump
epoch 4
fsid 2ae6d05a-229a-11ec-925e-52540000fa0c
last_changed 2021-10-01T09:33:53.880442+0000
created 2021-10-01T09:30:30.146231+0000
min_mon_release 16 (pacific)
election_strategy: 1
0: [v2:172.25.250.12:3300/0,v1:172.25.250.12:6789/0] mon.serverc.lab.example.com
1: [v2:172.25.250.10:3300/0,v1:172.25.250.10:6789/0] mon.clienta
2: [v2:172.25.250.13:3300/0,v1:172.25.250.13:6789/0] mon.serverd
3: [v2:172.25.250.14:3300/0,v1:172.25.250.14:6789/0] mon.servere
dumped monmap epoch 4
```



#### 3.2.4 管理集中式配置数据库

MON节点存储和维护集中式配置数据库，数据库在每个MON节点上的默认位置是`/var/lib/ceph/$fsid/mon.$host/store.db`，不建议更改数据库的位置。

随着时间的推移，数据库可能会变大，运行[ceph tell mon.$id compact]()命令用于压缩数据库以提高性能，另外，将mon_compact_on_start配置设置为true，以便在每次daemon启动时压缩数据库:

```bash
[ceph: root@clienta /]# ceph \
	config set mon mon_compact_on_start true 
```

定义基于数据库大小触发健康状态更改的阈值设置：

| 描述                                                 | 设置                   | 默认值     |
| -------------------------------------------------- | -------------------- | ------- |
| 配置数据库超过此大小时，将群集健康状态更改为HEALTH_WARN                  | mon_data_size_warn   | 15 (GB) |
| 当存储配置数据库的文件系统的剩余容量小于或等于该百分比时，将集群健康状态更改为HEALTH_WARN | mon_data_avail_warn  | 30 (%)  |
| 当存储配置数据库的文件系统的剩余容量小于或等于该百分比时，将集群健康状态更改为HEALTH_ ERR | mon_ data avail_crit | 5 (%)   |



#### 3.2.5 集群的身份验证

Ceph默认使用Ceph协议在Ceph组件之间进行加密身份验证，并使用共享密钥进行身份验证。使用cephadm部署集群时，默认启用cepphx。如果需要，可以禁用Cephx，但不建议这样做，因为它会削弱集群的安全性，为启用或禁用cephx，ceph config set命令可以管理多个设置

```bash
[ceph: root@clienta /]# ceph \
	config get mon auth_service_required
[ceph: root@clienta /]# ceph \
	config get mon auth_cluster_required
[ceph: root@clienta /]# ceph \
	config get mon auth_client_required
```

/etc/ceph目录和守护进程数据目录中包含cepphx密钥环文件，对于MONs，数据目录为`/var/lib/ceph/$fsid/mon.$host/`

使用ceph auth命令创建、查看和管理集群密钥。使用cephauthtool命令创建key-ring文件

下面的命令为MON节点创建一个密钥环文件

```bash
[ceph: root@clienta /]# ceph-authtool \
	--create-keyring /tmp/ceph.mon.keyring \
	--gen-key \
	-n mon \
	--cap mon 'allow *'
```

cephadm工具在/etc/ceph目录下创建client.admin用户，它允许运行管理命令和创建其他ceph客户端用户帐户



### 3.3 配置集群网络

#### 3.3.1 配置公共网络和集群网络

public网络是所有Ceph集群通信的默认网络，cephadm工具假设第一个MON守护进程IP地址的网络是public网络，新的MON守护进程部署在public网络中，除非显式地定义了不同的网络

Ceph客户端通过集群的public网络直接向osd发出请求，OSD复制和恢复流量使用public网络，除非为此配置单独的cluster网络

配置单独的cluster网络可以通过减少public网络流量负载和将客户端流量与后端OSD操作流量分离来提高集群性能

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/configure/networks-ceph-osd.svg)

执行以下步骤，为单独的集群网络配置节点：

1. 在每个集群节点上配置一个额外的网络接口

2. 在每个节点的新网口上配置相应的cluster网络IP地址

3. 使用cephadm bootstrap命令的--cluster- network选项在集群bootstrap创建cluster网络

可以使用集群配置文件来设置public和cluster网络。每个网络可以配置多个子网，子网之间以“，”分隔。子网使用CIDR符号表示，例如:172.25.250.0/24

```ini
[global] 
public_network = 172.25.250.0/24, 172.25.251.0/24 
cluster_network = 172.25.249.0/24 
```

可以使用ceph config set命令或ceph config assimilate-conf命令更改public和cluster网络



##### 配置特定的守护进程

MON守护进程绑定特定的IP地址，而MGR、OSD和MOS守护进程默认绑定任何可用的IP地址，在Red Hat Ceph Storage 5中，cephadm通过对大多数服务使用public网络在任意主机上部署守护进程，为了处理cephadm部署新守护进程的位置，可以定义一个特定的子网供服务使用，只有IP地址在同一子网的主机才会考虑部署该服务。

设置172.25.252.0/24子网到MON守护进程

```bash
[ceph: root@node /)# ceph \
	config set mon public_network 172.25.252.0/24
```

这个示例命令等价于集群配置文件中的下面的[mon]部分

```ini
[mon) 
public_network = 172.25.252.0/24 
```

使用ceph orch daemon add命令手动将守护进程部署到特定的子网或IP地址

```bash
[ceph: root@node /)# ceph orch \
	daemon add mon cluster-host02:172.25.251.0/24 
[ceph: root@node /)# ceph orch \
	daemon rm mon.cluster-host01
```

不建议使用运行时ceph orch守护进程命令进行配置更改，相反，建议使用服务规范文件作为管理Ceph集群的方法



##### 运行IPV6

ms_bind_ipv4的缺省值为true, ms_bind_ipv6的缺省值为false，要将Ceph守护进程绑定到IPv6地址，需要在集群配置文件中设置ms_bind_ipv6为true，设置ms_bind_ipv4为false

```ini
[global] 
public_network = <IPv6 public-network/netmask>
cluster_network = <IPv6 cluster-network/netmask>
```



##### 启用巨型帧

建议在存储网络上配置网络MTU以支持巨型帧，这可能会提高性能，在集群网口上配置MTU值为9000，以支持巨型帧

同一通信路径下的所有节点和网络设备的MTU值必须相同。对于bound网口，配置bound网口的MTU值后，底层接口继承相同的MTU值



#### 3.3.2 配置网络安全

通过减少public网络上的攻击面，挫败针对集群的某些类型的拒绝服务(DoS)攻击，并防止osd之间的通信中断，配置单独的cluster网络还可以提高集群的安全性和可用性。当osd之间的通信中断时，可以防止客户端读写数据

将后端OSD流量隔离到自己的网络中可能有助于防止public网络上的数据泄露，为保证后端cluster网络安全，请确保流量不能在cluster与public之间路由



#### 3.3.3 配置防火墙规则

Ceph OSD和MDS默认绑定的TCP端口范围为6800 ~ 7300。要配置不同的范围，请修改ms_bind_port_min和ms_bind_port_max设置

下表列出了Red Hat Ceph Storage 5的默认端口。

| 服务名称                      | 端口                               | 描述                                                                                                                               |
| ------------------------- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Monitor (MON)             | 6789/TCP (msgr),3300/TCP (msgr2) | Ceph集群内的通信                                                                                                                       |
| OSD                       | 6800-7300/TCP                    | 每个OSD使用3个端口:1个用于通过public与客户端和MONs通信；一个用于通过cluster网络向其他osd发送数据，如果前者不存在，则通过public网络发送数据；另一个用于在cluster网络或public网络上交换心跳数据包，如果前者不存在的话 |
| Metadata Server(MDS)      | 6800-7300/TCP                    | 与Ceph元数据服务器通信                                                                                                                    |
| Dashboard/Manager(MGR)    | 8443/TCP                         | 通过SSL与Ceph管理器仪表板通信                                                                                                               |
| Manager RESTful Module    | 8003/TCP                         | 通过SSL与Ceph Manager RESTful模块通信                                                                                                   |
| Manager Prometheus Module | 9283/TCP                         | 与Ceph Manager Prometheus插件的通信                                                                                                    |
| Prometheus Alertmanager   | 9093/TCP                         | 与Prometheus Alertmanager服务的通信                                                                                                    |
| Prometheus Node Exporter  | 9100/TCP                         | 与Prometheus Node Exporter守护进程通信                                                                                                  |
| Grafana server            | 3000/TCP                         | 与Grafana服务沟通                                                                                                                     |
| Ceph Object Gateway (RGW) | 80/TCP                           | 与Ceph RADOSGW通信。如果client.rgw配置段为空，Cephadm使用默认的80端口                                                                               |
| Ceph iSCSI Gateway        | 9287/TCP                         | 与Ceph iSCSI网关通信                                                                                                                  |

MONs总是在public网络上运行。为了保证的MON节点安全可以启用防火墙规则，需要配置带有public接口和public网络IP地址的规则。可以手动将端口添加到防火墙规则中

```bash
[root@node ~]# firewall-cmd --permanent --zone=public \
	--add-port=6789/tcp
[root@node ~]# firewall-cmd --reload 
```

还可以通过将ceph-mon服务添加到防火墙规则中来保护MON节点

```bash
[root@node ~]# firewall-cmd --permanent --zone=public \
	--add-service=ceph-mon 
[root@node ~]# firewall-cmd --reload
```

为了配置cluster网络，osd需要同时配置public网络和cluster网络的规则，客户端通过public连接osd, osd之间通过cluster网络通信

为了保护OSD不受防火墙规则的影响，需要配置相应的规则网口和IP地址

```bash
[root@node ~]# firewall-cmd --permanent \
	--zone=<public-or-cluster> --add-port=6800-7300/tcp 
[root@node ~]# firewall-cmd --reload
```

也可以通过在防火墙规则中添加ceph服务来保护OSD的安全

```bash
[root@node ~]# firewall-cmd --permanent \
	--zone=<public-or-cluster> --add-service=ceph 
[root@node ~]# firewall-cmd --reload
```



## 4. 创建对象存储集群组件

### 4.1 使用逻辑卷创建 BlueStore OSD

#### 4.1.2 BlueStore 简介

BlueStore 取代 FileStore 作为 OSD 的存储后端。FileStore 现已弃用

FileStore 将对象存储为块设备基础上的文件系统（通常是 XFS）中的文件。BlueStore 将对象直接存储在原始块设备上，免除了对文件系统层的需要，从而提高了读写操作速度

##### BlueStore 架构

Ceph 集群中存储的对象具有集群范围的唯一标识符、二进制对象数据和对象元数据，BlueStore 将 对象元数据存储在块数据库中，块数据库将元数据作为键值对存储在 RocksDB 数据库中，这是一种高性能的键值存储，块数据库驻留于存储设备上的一个小型 BlueFS 分区，BlueFS 是一种最小的文件系统，设计用于保存 RocksDB 文件，BlueStore 利用预写式日志 (WAL) 以原子式式将数据写入到块设备。预写式日志执行日志记录功能，并记录所有事务

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/component/component-bluestore-ceph-osd.svg)



##### BlueStore 性能

FileStore 写入到日志，然后从日志中写入到块设备。
BlueStore 可避免这种双重写入的性能损失，直接将数据写入块设备，同时使用单独的数据流将事务记录到预写式日志，当工作负载相似 时，BlueStore 的写操作速度约为 FileStore 的两倍，如果在集群中混用不同的存储设备，您可以自定义 BlueStore OSD 来提入性能。创建新的 BlueStore OSD 时，默认为将数据、块数据库和预写式日志都放置到同一个块设备上。从数据中分离块数据库和预写式日志，并将它们放入更快速的 SSD 或 NVMe 设备，或许能提高性能。

如果将块数据库或预写式日志放置到与对象数据不同的存储设备上，或许能够提升性能，但条件是这个设备的速度要快于主要存储设备。例如，如果对象数据位于 HDD设备上，可以通过将块数据库放在 SSD 设备上并将预写式日志放到 NVMe 设备上来提高性能

使用服务规范文件定义BlueStore数据、块数据库和预写日志设备的位置。示例如下：指定OSD服务对应的BlueStore设备

```yaml
service_type: osd
service_id: osd_example
placement:
  host_pattern: '*'
data_devices:
  paths:
    - /dev/vda
db_devices: 
  paths: 
    - /dev/nvme0
wal_devices:
  paths: 
    - /dev/nvme1
```

BlueStore 存储后端提供下列功能：

1. 允许将不同的设备用于数据、块数据库和**预写式日志** (WAL)

2. 支持以虚拟方式使用HDD、SSD 和 NVMe 设备的任意组合

3. 通过提高元数据效率，可以消除对存储设备的双重写入

以下图表显示了 BlueStore 与较旧 FileStore 解决方案的性能对比

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/component/component-radosbench-write.svg)

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/component/component-radosbench-read.svg)

BlueStore 在用户空间内运行，管理自己的缓存，并且其内存占用比FileStore 少。如有需要，可以手动调优 BlueStore 参数，BlueStore使用RocksDB存储键值元数据，BlueStore默认是自调优，但如果需要，可以手动调优BlueStore参数，

BlueStore分区写数据的块大小为bluestore_ min_alloc_size参数的大小，缺省值为4kib，如果要写入的数据小于chunk的大小，则BlueStore将chunk的剩余空间用0填充，建议将该参数设置为裸分区上最小的典型写操作的大小，建议将FileStore osd重新创建为BlueStore，以利用性能改进并维护红帽支持



##### 介绍BlueStore数据库分片

BlueStore可以限制存储在RocksDB中的大型map对象的大小，并将它们分布到多个列族中，这个过程被称为分片，使用sharding时，将访问修改频率相近的密钥分组，以提高性能和节省磁盘空间。Sharding可以缓解RocksDB压实的影响，压缩数据库之前，RocksDB需要达到一定的已用空间，这会影响OSD性能，这些操作与已用空间级别无关，可以更精确地进行压缩，并将对OSD性能的影响降到最低

Red Hat建议配置的RocksDB空间至少为数据设备大小的4%

在Red Hat Ceph Storage 5中，默认启用分片，从早期版本迁移过来的集群的osd中没有启用分片，从以前版本迁移过来的集群中的osd将不会启用分片

使用ceph config  get验证一个OSD是否启用了sharding，并查看当前的定义

```bash
[ceph: root@clienta /]# ceph \
	config get osd.1 bluestore_rocksdb_cf

[ceph: root@clienta /]# ceph \
	config get osd.1 bluestore_rocksdb_cfs
m(3) p(3,0-12) O(3,0-13)=block_cache={type=binned_lru} L P
```

在大多数Ceph用例中，默认值会带来良好的性能。生产集群的最佳分片定义取决于几个因素，Red Hat建议使用默认值，除非面临显著的性能问题。在生产升级的集群中，可能需要权衡在大型环境中为RocksDB启用分片所带来的性能优势和维护工作

可以使用BlueStore管理工具ceph-bluestore-tool重新共享RocksDB数据库，而无需重新配置osd。要重新共享一个OSD，需要停止守护进程并使用--sharding选项传递新的sharding定义。--path选项表示OSD数据Location，默认为`/var/lib/ceph/$fsid/osd.$ID/`

```bash
[ceph: root@node /]# ceph-bluestore-tool \
	--path <data path> \
	--sharding="m{3) p{3,0-12) 0(3,0-13)= block_cache={type=binned_lru} L P" reshard
```



#### 4.1.3 提供 BlueStore OSD

作为存储管理员，可以使用Ceph Orchestrator服务在集群中添加或删除osd，添加OSD时，需要满足以下条件:

1. 设备不能有分区

2. 设备不能被挂载

3. 设备空间要求5GB以上

4. 设备不能包含Ceph BlueStore OSD

使用[ceph orch device ls]()命令列出集群中主机中的设备

```bash
[ceph: root@clienta /]# ceph orch device ls
Hostname                 Path      Type  Serial  Size   Health   Ident  Fault  Available  
clienta.lab.example.com  /dev/vdb  hdd           10.7G  Unknown  N/A    N/A    Yes        
clienta.lab.example.com  /dev/vdc  hdd           10.7G  Unknown  N/A    N/A    Yes        
clienta.lab.example.com  /dev/vdd  hdd           10.7G  Unknown  N/A    N/A    Yes        
```

Available列中标签为Yes的节点为OSD发放的候选节点。如果需要查看已使用的存储设备，请使用ceph device ls命令

使用[ceph orch device zap]()命令准备设备，该命令删除所有分区并清除设备中的数据，以便将其用于资源配置，使用--force选项确保~~删除~~上一个OSD可能创建的任何分区

```bash
[ceph: root@node /]# ceph orch \
	device zap node /dev/vda --force
```



##### 回顾BlueStore配置方法

在rhcs5中，cephadm是提供和管理osd的推荐工具，它在后台使用cephvolume工具来进行OSD操作，cephadm工具可能看不到手动操作使用ceph -volume，建议仅为故障排除手动执行ceph-volume OSD

有多种方式提供OSDs与cephadm，根据需要的集群行为考虑适当的方法

##### 基于Orchestrator提供

Orchestrator服务可以发现集群主机之间的可用设备，添加设备，并创建OSD守护进程。Orchestrator处理在主机之间平衡的新osd的放置，以及处理BlueStore设备选择

使用[ceph orch apply osd --all-available-devices]()命令提供所有可用的、未使用的设备

```bash
[ceph: root@node /]# ceph \
	orch apply osd --all-available-devices
```

该命令创建一个OSD服务，名为osd.all-available-devices，使Orchestrator服务能够管理所有OSD供应。
Orchestrator从集群中的新磁盘设备和使用ceph orch设备zap命令准备的现有设备自动创建osd

若要禁用Orchestrator自动供应osd，请将非托管标志设置为true

```bash
[ceph: root@node /]# ceph \
	orch apply osd --all-available-devices --unmanaged=true
```

##### 基于指定目标提供

可以使用特定的设备和主机创建OSD进程，使用ceph orch daemon add命令创建带有指定主机和存储设备的单个OSD守护进程

```bash
[ceph: root@node /]# ceph orch daemon add osd node:/dev/vdb
```

停止OSD进程，使用带OSD ID的ceph orch daemon stop命令

```bash
[ceph: root@node /]# ceph arch daemon stop osd.12 
```

使用ceph orch daemon rm命令移除OSD守护进程

```bash
[ceph: root@node /)# ceph orch daemon rm osd.12
```

释放一个OSD ID，使用ceph osd rm命令

```bash
[ceph: root@node /]# ceph osd rm 12
```

##### 基于服务规范文件提供

使用服务规范文件描述OSD服务的集群布局，可以使用过滤器自定义服务发放，通过过滤器，可以在不知道具体硬件架构的情况下配置OSD服务，这种方法在自动化集群引导和维护窗口时很有用

下面是一个示例服务规范YAML文件，它定义了两个OSD服务，每个服务使用不同的过滤器来放置和BlueStore设备位置

```yaml
service_type: osd
service_id: osd_size_and_model
placement:
  host_pattern: '*'
data_devices:
  size: '100G:'
db_devices: 
  model: My-Disk 
wal_devices:
  size: '10G:20G' 
unmanaged: true
---
service_type: osd 
service_id: osd_host_and_path 
placement: 
  host_pattern: 'node[6-10]' 
data_devices: 
  paths: 
    - /dev/sdb 
db_devices: 
  paths: 
    - /dev/sdc 
wal_devices: 
  paths: 
    - /dev/sdd 
encrypted: true
```

osd_size_and_model服务指定任何主机都可以用于放置，并且该服务将由存储管理员管理，数据设备必须有一个100gb或更多的设备，提前写日志必须有一个10 - 20gb的设备。数据库设备必须是My-Disk型号

osd_host_and_path服务指定目标主机必须在node6和node10之间的节点上提供，并且服务将由协调器服务管理，数据、数据库和预写日志的设备路径必须 /dev/sdb、 /dev/sdc 和 /dev/sdd，此服务中的设备将被加密

执行ceph orch apply命令应用服务规范

```bash
[ceph: root@node /]# ceph orch apply -i service_spec.yaml 
```

##### 其他OSD实用工具

ceph-volume命令是将逻辑卷部署为osd的模块化工具，它在框架类型中使用了插件，[ceph -volume]()实用程序支持lvm插件和原始物理磁盘，它还可以管理由遗留的[ceph-disk]()实用程序提供的设备

使用ceph-volume lvm命令手动创建和删除BlueStore osd，在块存储设备/dev/vdc上创建一个新的BlueStore OSD:

```bash
[ceph: root@node /]# ceph-volume \
	lvm create --bluestore --data /dev/vdc 
```

create子命令的另一种选择是使用ceph-volume lvm prepare和ceph -volume lvm activate子命令，通过这种方法，osd逐渐引入到集群中，可以控制新的osd何时处于up或in状态，因此可以确保大量数据不会意外地在osd之间重新平衡

prepare子命令用于配置OSD使用的逻辑卷，可以指定逻辑卷或设备名称，如果指定了设备名，则会自动创建一个逻辑卷

```bash
[ceph: root@node /]# ceph-volume \
	lvm prepare --bluestore --data /dev/vdc 
```

activate子命令为OSD启用一个systemd单元，使其在启动时启动，使用activate子命令时，需要从命令ceph-vo lume lvm list的输出信息中获取OSD的fsid (UUID)。提供唯一标识符可以确保激活正确的OSD，因为OSD id可以重用

```bash
[ceph: root@node /]# ceph-volume \
	lvm activate <osd-fsid>
```

创建OSD后，使用systemctl start ceph-osd@$id命令启动OSD，使其在集群中处于up状态

batch子命令可以同时创建多个osd。

```bash
[ceph: root@node /]# ceph-volume \
	lvm batch --bluestore /dev/vdc /dev/vdd /dev/nvme0n1 
```

inventory子命令用于查询节点上所有物理存储设备的信息

```bash
[ceph: root@node /]# ceph-volume inventory
```



### 4.2 创建和配置池

#### 了解池的含义

1. 池是存储对象的逻辑分区。Ceph客户端将对象写入池

2. Ceph客户机需要集群名称(默认情况下是Ceph)和一个监视器地址来连接到集群，Ceph客户端通常从Ceph配置文件中获取这些信息，或者通过指定为命令行参数来获取

3. Ceph客户端使用集群映射检索到的池列表来确定存储新对象的位置

4. Ceph客户端创建一个输入/输出上下文到一个特定的池，Ceph集群使用CRUSH算法将这些池映射到放置组，然后放置组映射到特定的osd

5. 池为集群提供了一层弹性，因为池定义了可以在不丢失数据的情况下发生故障的osd的数量

#### 池类型

可用的池类型有复制池和纠删代码池，工作负载的用例和类型可以帮助您确定要创建**复制池**还是**纠删代码池**

- 复制池是默认的池类型，通过将各个对象复制到多个 OSD 来发挥作用，它们需要更多的存储空间， 因为会创建多个对象副本，但读取操作不受副本丢失的影响
  对于经常访问并且需要快速读取性能的数据，复制池通常都是更好的选择。

- 纠删代码池需要的存储空间和网络带宽较小，但因为奇偶校验计算，计算开销会更高一些
  对于不需要频繁访问且不需要低延迟的数据，纠删代码池通常是更好的选择。

每一种池的恢复时间取决于特定的部署和故障情景

创建池后，不能修改池的类型

#### 池属性

在创建池时，您必须指定特定的属性： 

1. pool name，必须在集群中唯一

2. pool type，决定了池用于确保数据持久性的保护机制

3. replicated 类型，将每个对象的多个副本分发到集群中

4. erasure coded 类型，将每个对象分割为多个区块，并将它们与额外的纠删代码区块一起分发，以使用自动纠错机制来保护对象

5. 池中的 placement groups (PG) 数量，这将其对象存储到由 CRUSH 算法决定的一组 OSD 中

6. 可选的 CRUSH rule set，Ceph 使用它来标识要用于存储池对象的放置组

更改 osd_pool_default_pg_num 和 osd_pool_default_pgp_num 配置设置，以设置池的默认 PG 数

#### 创建复制池

Ceph通过为每个对象创建多个副本来保护复制池中的数据，Ceph使用CRUSH故障域来确定作用集的主要osd来存储数据，然后，Ceph使用CRUSH 故障域来决定主OSD来存储数据，然后住OSD查找当前的池副本数量并计算辅助OSD来写入数据，当主OSD收到写响应并完成写操作后，主OSD确认写成功到Ceph客户端，这样可以在一个或多个osd失效时保护对象中的数据

使用以下命令创建一个复制池

```bash
[ceph: root@node /]# ceph osd pool create pool-name pg-num pgp-num replicated crush-rule-name 
```

其中：

1. pool_name 是新池的名称

2. pg_num 是为这个池配置的放置组 (PG) 总数

3. pgp_num 是这个池的有效放置组数量，将它设置为与 pg_num 相等

4. replicated 指定这是复制池，如果命令中未包含此参数，这是默认值

5. crush-rule-name 是想要⽤于这个池的 CRUSH 规则集的名称，osd_pool_default_crush_replicated_ruleset 配置参数设置其默认值

在初始配置池之后，可以调整池中放置组的数量，如果pg_num和pgp_num被设置为相同的数字，那么以后任何对pg_num的调整都会自动进行调整pgp_num的值。如果需要，对pgp_num的调整会触发跨osd的pg移动，以实现更改，使用以下命令在池中定义新的pg数量

```bash
[ceph: root@node /]# ceph osd pool set my_pool pg_num 32
```

使用ceph osd pool create命令创建池时，不指定副本个数(size)，osd_pool _default size配置参数定义了副本的数量，默认值为3

```bash
[ceph: root@node /]# ceph config get mon osd_pool_default_size 
3 
```

使用ceph osd pool set pooI-name size number-of-replica 命令修改池大小，或者，更新osd_pool_default_size配置设置的默认设置

osd_pool_default_min_size参数设置一个对象的拷贝数，必须可以接受I/O的请求，缺省值为2

#### 配置Erasure编码池

Erasure编码池使用擦除编码代替复制来保护对象数据

存储在Erasure编码池中的对象被划分为多个数据块，这些数据块存储在单独的osd中，编码块的数量是根据数据块计算出来的，并存储在不同的osd中，当OSD出现故障时，编码块用于重建对象的数据，主OSD接收到写操作后，将写载荷编码成K+M块，通过Erasure编码池发送给备OSD

Erasure编码池使用这种方法来保护它们的对象，并且与复制池不同，它不依赖于存储每个对象的多个副本

总结Erasure编码池的工作原理:

1. 每个对象的数据被划分为k个数据块

2. 计算M个编码块

3. 编码块大小与数据块大小相同

4. 该对象总共存储在k + m个osd上

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/component/configuring-config-erasure.svg)

Erasure编码比复制更有效地利用存储容量，复制池维护一个对象的n个副本，而纠删编码只维护k + m块，例如，3副本的复制池使用3倍的存储空间，k=4和m=2的Erasure编码池只使用1.5倍的存储空间

Red Hat支持以下k+m值，从而产生相应的可用到原始比率:

4 + 2(1:1.5比率)

8 + 3(1:1.375比率)

8 + 4(1:1.5比率)

erasure code开销的计算公式为nOSD * k / (k+m) * 0SD大小，例如，如果您有64个4TB的osd(总共256 TB)， k=8, m=4，那么公式是64 * 8 /(8+4)* 4 = 170.67，然后将原始存储容量除以开销，得到这个比率。256TB /170.67 TB = 1.5

与复制池相比，Erasure编码池需要更少的存储空间才能获得类似级别的数据保护，从而降低存储集群的成本和规模。但是，计算编码块会增加Erasure编码池的CPU处理和内存开销，从而降低整体性能

使用以下命令创建Erasure编码池

```bash
[ceph: root@node /]# ceph \
	osd pool create pool-name \
	pg-num pgp-num \
	erasure erasure-code-profile crush-rule-name 
```

其中：

1. pool-name 是新池的名称

2. pg-num 是这个池的放置组 (PG) 总数

3. pgp-num 是这个池的有效放置组数量，通常而言，这应当与 PG 总数相等

4. erasure 指定这是纠删代码池

5. erasure-code-profile 要使⽤的配置文件的名称，可以使用[ceph osd erasure-code-profile set]() 命令创建新的配置⽂件，配置文件定义 k 和 m 值，以及要使用的纠删代码池插件。默认情况下，Ceph 使用default 配置文件

6. crush-rule-name 是要用于这个池的 CRUSH 规则集的名称。如果不设置，Ceph 将使用纠删代码池配置文件中定义的规则集

可以在池上配置放置组自动伸缩，自动缩放允许集群计算放置组的数量，并自动选择适当的pg_num值，自动缩放在Red Hat Ceph Storage 5中是默认启用的

集群中的每个池都有一个pg_autoscale_mode选项，其值为on、off或warn

1. on:启用自动调整池的PG计数

2. off:禁用池的PG自动伸缩

3. warn:当PG计数需要调整时，引发健康警报并将集群健康状态更改为HEALTH_WARN

本例在Ceph MGR节点上启用pg_autoscaler模块，并将池的自动缩放模式设置为on:

```bash
[ceph: root@node /]# ceph mgr module enable pg_autoscaler 
module 'pg_autoscaler' is already enabled (always-on) 
[ceph: root@node /]# ceph \
	osd pool set pool-name pg_autoscale_mode on 
set pool 7 pg_autoscale_mode to on
```

纠删代码池不能使用对象映射特性，对象映射是一个对象索引，跟踪rbd对象块的分配位置，拥有池的对象映射可以提高调整大小、导出、扁平化和其他操作的性能。

#### Erasure Code配置文件

Erasure Code配置文件配置你的Erasure Code池用来存储对象的数据块和编码块的数量，以及使用哪些Erasure Code插件和算法

创建配置文件来定义不同的纠删编码参数集，Ceph在安装过程中自动创建默认概要文件，这个配置文件被配置为将对象分为两个数据块和一个编码块

使用以下命令创建一个新的概要文件

```bash
[ceph: root@node /]# ceph \
	osd erasure-code-profile set profile-name arguments
```

以下是可用的参数:

**k**

跨osd分割的数据块的数量，缺省值为2

**m**

数据不可用前可能发生故障的osd数量，缺省值为1

**directory**

这个可选参数是插件库的位置，默认值为/usr/lib64/ceph/erasure-code

**plugin**

此可选参数定义要使用的纠删编码算法

**crush-failure-domain**

这个可选参数定义了CRUSH故障域，它控制块的放置，默认情况下，它被设置为host，这确保一个对象的块被放置在不同主机的osd上，如果设置为osd，那么一个对象的chunk可以放置在同一主机上的osd上，将故障域设置为osd，会导致主机上所有的osd故障，弹性较差，主机失败，可以定义并使用故障域，以确保块放置在不同数据中心机架或其他指定的主机上的osd上

**crush-device-class**

此可选参数仅为池选择由该类设备支持的osd，典型的类可能包括hdd、ssd或nvme

**crush-root**

该可选参数设置CRUSH规则集的根节点

**key=value**

插件可能具有该插件特有的键值参数

**technique**

每个插件提供一组不同的技术，用于实现不同的算法

不能修改已存在存储池的erasure code配置文件

使用[ceph osd erasure-code-profile ls]() 命令列出已存在的配置文件

使用[ceph osd erasure-code-profile get]()命令查看已创建配置文件的详细信息

使用[ceph osd erasure-code-profile rm]()删除已存在的配置文件

#### 管理和操作池

可以查看、修改已创建的存储池，并修改存储池的配置信息

1. 使用[ceph osd pool rename]()命令重命名池，这不会影响存储在池中的数据，如果重命名池，并且为经过身份验证的用户提供了每个池的功能，则必须使用新的池名称更新用户的功能

2. 使用[ceph osd pool delete]()命令删除osd池

3. 使用[ceph osd pool set pool_name nodelete true]()命令可以防止指定池被删除，使用实例将nodedelete设置为false以允许删除池

4. 使用[ceph osd pool set]()和[ceph osd pool get]()命令查看和修改池配置

5. 使用[ceph osd lspoolls]()和[ceph osd pool ls detail]()命令列出池和池配置设置

6. 使用[ceph df]()和[ceph osd pool stats]()命令列出池的使用情况和性能统计信息

7. 使用[ceph osd pool application enable]()命令启用池中的Ceph应用，应用类型为Ceph File System的 [cepfs]()、Ceph Block Device的[rbd]()、RADOS Gateway的[rgw]()

8. 使用[ceph osd pool set-quota]()命令设置池配额，限制池中最大字节数或最大对象数

当存储池达到设置的配额时，将阻止操作，可以通过将配额值设置为0来删除配额

配置这些设置值的示例，以启用对池重新配置的保护:

**osd_ pool _default flag_nodelete**

设置池上的nodedelete标志的默认值，设置该值为true，以防止删除池

**osd_pool_default_flag_nopgchange**

设置池上的nopgchange标志的默认值，设置为true可以防止pg_ num和pgp_num的变化

**osd_pool_default_flag_nosizechange**

设置池的nosizechange标志的默认值。设置该值为true，以防止池的大小变化

#### 池名称空间

命名空间是池中对象的逻辑组，可以限制对池的访问，以便用户只能在特定的名称空间中存储或检索对象，名称空间的一个优点是限制用户访问池的一部分，名称空间对于限制应用程序的存储访问非常有用，它们允许对池进行逻辑分区，并将应用程序限制到池中的特定名称空间。

可以为每个应用程序专用一个完整的池，但是拥有更多的池意味着每个OSD拥有更多的pg，而pg在计算上是非常昂贵的，随着负载的增加，这可能会降低OSD的性能，使用名称空间，可以保持池的数量相同，而不必为每个应用程序专用整个池

要在名称空间中存储对象，客户机应用程序必须提供池和名称空间名称。默认情况下，每个池包含一个名称为空的名称空间，称为默认名称空间。

使用rados命令从池中存储和检索对象。使用-n name和--namespace=name选项指定要使用的池和命名空间

下面以将/etc/services文件作为srv对象存储在系统命名空间下的mytestpool池中为例

```bash
[ceph: root@node /]# rados \
	-p mytestpool -N system   put srv /etc/services 
[ceph: root@node /]# rados \
	-p mytestpool -N system   ls
```

使用--all选项列出池中所有名称空间中的所有对象，要获得JSON格式的输出，请添加--format=j son-pretty选项

下面的例子列出了mytestpool池中的对象。mytest对象有一个空的名称空间。其他对象属于system或flowers名称空间

```bash
[ceph: root@node /]# rados \
	-p mytestpool --all ls 
[ceph: root@node /]# rados \
	-p mytestpool --all ls --format=json-pretty 
...
```

### 4.3 管理Ceph认证

#### 用户身份验证

Red Hat Ceph Storage使用cephx协议对集群中客户端、应用程序和守护进程之间的通信进行授权。cephx协议基于共享密钥

安装过程默认启用cephx，因此集群需要所有客户端应用程序进行用户身份验证和授权，Ceph使用用户帐户有以下几个目的：

1. 用于Ceph守护进程之间的内部通信

2. 对于通过librados库访问集群的客户机应用程序

3. 为集群管理员

Ceph守护进程使用的帐户名称与其关联的守护进程osd.1或mgr.serverc相匹配，并且其在安装过程中创建

使用librados的客户端应用程序所使用的帐户具有`client.`名称前缀，例如，在集成OpenStack和Ceph时，通常会创建一个专用的client.openstack用户帐户。对于Ceph对象网关，安装会创建一个专用的client.rgw.hostname用户帐号，在librados之上创建定制软件的开发人员应该创建具有适当功能的专用帐户

管理员帐户名也具有client.前缀。在运行ceph、rados等命令时使用，安装程序创建超级用户帐户client.admin，具有允许帐户访问所有内容和修改集群配置的功能。Ceph使用client.admin帐户用于运行管理命令，除非使用--name或--id选项明确指定用户名

可以设置CEPH_ARGS环境变量来定义诸如集群名称或用户ID等参数

```bash
[ceph: root@node /]# export CEPH_ARGS="--id cephuser" 
```

Ceph-aware应用程序的最终用户没有Ceph集群上的帐户。相反，他们访问应用程序，然后应用程序代表他们访问Ceph。从Ceph的角度来看，应用程序就是客户端。应用程序可以通过其他机制提供自己的用户身份验证

下图概述了应用程序如何提供自己的用户身份验证

<img width=60% src='https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/component/configuring-config-auth.svg'>

Ceph对象网关有自己的用户数据库来认证Amazon S3和Swift用户，但使用client.rgw.hosttname用于访问集群的帐号

#### Keyring 文件

对于身份验证，客户端配置一个Ceph用户名和一个包含用户安全密钥的密钥环文件，Ceph在创建每个用户帐户时为其生成密匙环文件，但是，必须将此文件复制到需要它的每个客户机系统或应用程序服务器

在这些客户机系统上，librados使用来自/etc/ceph/ceph.conf的密匙环参数。Conf配置文件以定位密钥环文件。默认值为`/etc/ceph/$cluster.$name.keyring`密匙环。例如，对于client.openstack帐户，密钥环文件/etc/ceph/ceph.client.openstack.keyring密匙环

密钥环文件以纯文本的形式存储密钥，对文件进行相应的Linux文件权限保护，仅允许Linux授权用户访问，只在需要Ceph用户的密匙环文件进行身份验证的系统上部署它

#### 传输密钥

cephx协议不以纯文本的形式传输共享密钥，相反，客户机从Monitor请求一个会话密钥，Monitor使用客户机的共享密钥加密会话密钥，并向客户机提供会话密钥，客户机解密会话密钥并从Monitor请求票据，以对集群守护进程进行身份验证。这类似于Kerberos协议，cephx密钥环文件类似于Kerberos keytab文件

#### 配置用户身份验证

使用命令行工具，如ceph、rados和rbd，管理员可以使用--id和--keyring选项指定用户帐户和密钥环文件。如果没有指定，命令作为client.admin进行身份验证

在本例中，ceph命令作为client.operator3进行身份验证列出可用的池

```bash
[ceph: root@node /]# ceph \
	--id operator3 \
	osd lspools
```

在使用--id 的时候不适用client.的前缀，--id会自动使用client.前缀，而使用--name的时候就需要使用client.的前缀

如果将密钥环文件存储在默认位置，则不需要--keyring选项。cephadm shell自动从/etc/ceph/目录挂载密钥环

#### 配置用户授权

创建新用户帐户时，授予群集权限，以授权用户的群集任务，cephx中的权限被称为能力，可以通过守护进程类型(mon、osd、mgr或mds)授予它们，使用功能来根据应用程序标记限制或提供对池、池的名称空间或一组池中的数据的访问。功能还允许集群中的守护进程相互交互

#### Cephx能力

在cephx中，对于每个守护进程类型，有几个可用的功能：

**R** 授予读访问权限，每个用户帐户至少应该对监视器具有读访问权限，以便能够检索CRUSH map

**W** 授予写访问权限，客户端需要写访问来存储和修改osd上的对象。对于manager (MGRs)， w授予启用或禁用模块的权限

**X** 授予执行扩展对象类的授权，这允许客户端对对象执行额外的操作，比如用rados lock get或list列出RBD图像

***** 授予完全访问权

**class-read和class-write** 是x的子集，你通常在RBD池中使用它们

本例创建了formyappl用户帐户，并赋予了从任意池中存储和检索对象的能力：

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.formyappl \
	mon 'allow r' \
	osd 'allow rw'
```

#### 使用配置文件设置能力

Cephx提供预定义的功能配置文件，在创建用户帐户时，利用配置文件简化用户访问权限的配置

本例通过rbd配置文件定义新的forrbd用户帐号的访问权限，客户端应用程序可以使用该帐户使用RADOS块设备对Ceph存储进行基于块的访问

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.forrbd \
	mon 'profile rbd' \
	osd 'profile rbd'
```

rbd-read-only配置文件的工作方式相同，但授予只读访问权限，Ceph利用其他现有的配置文件在守护进程之间进行内部通信，不能创建自己的配置文件，Ceph在内部定义它们

下表列出了默认安装下Ceph的功能

|         能力          | 描述                                                         |
| :-------------------: | ------------------------------------------------------------ |
|        `allow`        | 授予允许能力                                                 |
|          `r`          | 赋予用户读访问权限，需要监视器来检索CRUSH map                |
|          `w`          | 赋予用户对对象的写访问权                                     |
|          `x`          | 使用户能够调用类方法(即读取和写入)并在监视器上执行身份验证操作 |
|      class-read       | 赋予用户调用类读取方法的能力，x的子集                        |
|      class-write      | 赋予用户调用类写入方法的能力，x的子集                        |
|           *           | 为用户提供特定守护进程或池的读、写和执行权限，以及执行管理命令的能力 |
|     `profile osd`     | 允许用户作为OSD连接到其他OSD或监视器，授予osd权限，使osd能够处理复制心跳流量和状态报告。 |
| profile bootstrap-osd | 允许用户引导一个OSD，这样用户在引导一个OSD时就有了添加key的权限 |
|     `profile rbd`     | 允许用户对Ceph块设备进行读写访问                             |
| profile rbd-read-only | 为用户提供对Ceph块设备的只读访问权限                         |

#### 限制访问

限制用户OSD的权限，使用户只能访问自己需要的池

下面的例子创建了formyapp2用户，并限制了他们对myapp池的读写权限:

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.formyapp2 \
	mon 'allow r' \
	osd 'allow rw pool=myapp'
```

如果在配置功能时没有指定池，那么Ceph将在所有现有的池上设置它们，cephx机制可以通过其他方式限制对对象的访问:

**通过对象名称前缀**，下面的示例限制对任何池中名称以pref开头的对象的访问

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.formyapp3 \
	mon 'allow r' \
	osd 'allow rw object_prefix pref'
```

通过namespace，实现namespace来对池中的对象进行逻辑分组，然后可以将用户帐户限制为属于特定namespace的对象：

```bash
[ceph: root@node /)# ceph auth \
	get-or-create client.designer \
	mon 'allow r' \
	osd 'allow rw namespace=photos'
```

通过路径，Ceph文件系统(cepphfs)利用这种方法来限制对特定目录的访问，下面的例子创建了一个新的用户帐户webdesigner，它只能访问/webcontent目录及其内容:

```bash
[ceph: root@node /]# ceph \
	fs authorize WEBFS \
	client.webdesigner \
  /webcontent rw 
[ceph: root@node /]# ceph auth get client.webdesigner 
exported keyring for client .webdesigner 
[client.webdesigner] 
key = AQBrVE9aNwoEGRAApYR6m71ECRzUlLpp4wEJkw== 
caps mds = "allow rw path=/webcontent" 
caps mon = "allow r" 
caps osd = "allow rw pool=cephfs_data"
```

通过monitor命令，这种方法将管理员限制在特定的命令列表中，创建operator1用户帐户并限制其访问两个命令的示例如下:

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.operator1 \
	mon 'allow r, allow command "auth get-or-create", allow command "auth list" '
```

#### 用户管理

需要查询现有用户，使用ceph auth list命令

```bash
[ceph: root@node /]# ceph auth list 
... output omitted ... 
osd.0 
key: AQBW6Tha5z6OIhAAMQ7nY/4MogYecxKqQxX1sA== 
caps : [mgr] allow profile osd
caps: [mon] allow profile osd 
caps: [osd] allow * 
client.admin 
key: AQCi6Dhajw7pIRAA/ECkwyipx2/raLWjgbklyA== 
caps: [mds] allow * 
caps: [mgr] allow * 
caps: [mon] allow * 
caps: [osd] allow * 
. . . output omitted ... 
```

要获取特定帐户的详细信息，使用ceph auth get命令:

```bash
[ceph: root@node /]# ceph auth get client.admin 
exported keyring for client.admin 
[client . ad min] 
key = AQCi6Dhajw7pIRAA/ECkwyipx2/raLWj gbklyA== 
caps mds = "allow *" 
caps mgr = "allow *" 
caps mon = "allow *" 
caps osd = "allow *" 
```

可以打印密钥：

```bash
[ceph: root@node /]# ceph auth print-key client.adrnin 
AQCi6Dhajw7pIRAA/ECkwyipx2/raLWjgbklyA== 
```

需要导出和导入用户帐号，使用ceph auth export和ceph auth import命令

```bash
[ceph: root@node /]# ceph auth \
	export client.operator1 > ~/operatorl.export 
[ceph: root@node /]# ceph auth \
	import -i ~/operator1.export 
```

#### 创建新用户帐户

ceph auth get-or-create命令创建一个新用户帐户并生成它的密钥，该命令默认将该密钥打印到stdout，因此通常会添加-o选项来将标准输出保存到密钥环文件中。

本例创建了对所有池具有读写权限的app1用户帐户，并将密钥环文件存储在/etc/ceph/ceph.client.app1.keyring

```bash
[ceph: root@node /]# ceph auth \
	get-or-create client.app1 \
	mon 'allow r' \
	osd 'allow rw' \
	-o /etc/ceph/ceph.client.app1.keyring
```

身份验证需要密匙环文件，因此必须将该文件复制到使用此新用户帐户操作的所有客户端系统

#### 修改用户能力

用ceph auth caps命令修改用户帐户的能力，这个例子修改了osd上的appuser account功能，只允许对myapp池进行读写访问:

```bash
[ceph: root@node /]# ceph auth \
	caps client.app1 \
	mon 'allow r' \
	osd 'allow rw pool=myapp' 
updated caps for client.app1 
```

ceph auth caps命令覆盖现有功能，使用该命令时，必须为所有守护进程指定完整的功能集，而不仅仅是要修改的那些。定义一个空字符串来删除所有功能

```bash
[ceph: root@node /]# ceph auth caps client.app1 osd '' 
updated caps for client.app1 
```

#### 删除用户帐号

ceph auth del命令用于删除用户帐号

```bash
[ceph: root@node /]# ceph auth del client.app1
updated
```

然后可以删除相关的密钥环文件


## 5. 创建和管理自定义 CRUSH map

### 5.1 管理和定制CRUSH Map

#### 5.1.1 CRUSH和目标放置策略

Ceph通过一种称为CRUSH(可伸缩哈希下的受控复制)的放置算法来计算哪些osd应该持有哪些对象，对象被分配到放置组(pg)， CRUSH决定这些放置组应该使用哪个osd来存储它们的对象

##### CRUSH的算法

CRUSH算法使Ceph客户端能够直接与osd通信，这避免了集中式服务瓶颈，Ceph客户端和osd使用CRUSH算法高效地计算对象位置的信息，而不是依赖于一个中央查找表。Ceph客户端检索集群映射，并使用CRUSH映射从算法上确定如何存储和检索数据，通过避免单点故障和性能瓶颈，这为Ceph集群提供了大规模的可伸缩性

CRUSH算法的作用是将数据统一分布在对象存储中，管理复制，并响应系统增长和硬件故障，当新增OSD或已有OSD或OSD主机故障时，Ceph通过CRUSH在主OSD间实现集群对象的再平衡

##### CRUSH Map 组件

从概念上讲，一个CRUSH map包含两个主要组件：

**CRUSH层次结构**

这将列出所有可用的osd，并将它们组织成树状的桶结构

CRUSH层次结构通常用来表示osd的位置，默认情况下，有一个root桶代表整个层次结构，其中包含每个OSD主机的一个主机桶

OSD是树的叶子节点，默认情况下，同一个OSD主机上的所有OSD都放在该主机的桶中，可以自定义树状结构，重新排列，增加层次，将OSD主机分组到不同的桶中，表示其在不同的服务器机架或数据中心的位置

**至少有一条CRUSH规则**

CRUSH 规则决定了如何从这些桶中分配放置组的osd，这决定了这些放置组的对象的存储位置。不同的池可能会使用不同的CRUSH规则

##### CRUSH Bucket类型

CRUSH层次结构将osd组织成一个由不同容器组成的树，称为桶。对于大型安装，可以创建特定的层次结构来描述存储基础设施：数据中心、机架、主机和OSD设备。通过创建一个CRUSH map规则，可以使Ceph将一个对象的副本放在独立服务器上的osd上，放在不同机架的服务器上，甚至放在不同数据中心的服务器上

总而言之，桶是CRUSH层次结构中的容器或分支。osd设备是CRUSH等级中的叶子

一些最重要的桶属性有:

1. 桶ID，这些id为负数，以便与存储设备的id区分开来

2. 桶的名称

3. 桶的类型，默认映射定义了几种类型，可以使用ceph osd crush dump命令检索这些类型

桶类型包括root、region、datacenter、room、pod、pdu、row、rack、chassis和host，但你也可以添加自己的类型、位于层次结构根的桶属于根类型

Ceph在将PG副本映射到osd时选择桶内物品的算法。有几种算法可用:uniform、list、tree和straw2。每种算法都代表了性能和重组效率之间的权衡。
缺省算法为straw2

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/map/map-crush-default-hierarchy.svg)

#### 5.1.2 自定义故障和性能域

CRUSH映射是CRUSH算法的中心配置机制，可以编辑此map以影响数据放置并自定义CRUSH算法

配置CRUSH映射和创建单独的故障域允许osd和集群节点发生故障，而不会发生任何数据丢失。在问题解决之前，集群只是以降级状态运行

配置CRUSH映射并创建单独的性能域可以减少使用集群存储和检索数据的客户机和应用程序的性能瓶颈。
例如，CRUSH可以为hdd创建一个层次结构，为ssd创建另一个层次结构

定制CRUSH映射的一个典型用例是针对硬件故障提供额外的保护。
可以配置CRUSH映射以匹配底层物理基础设施，这有助于减轻硬件故障的影响

默认情况下，CRUSH算法将复制的对象放置在不同主机上的osd上。
可以定制CRUSH map，这样对象副本就可以跨osd放置在不同的架子上，或者放置在不同房间的主机上，或者放置在具有不同电源的不同架子上

另一个用例是将带有SSD驱动器的osd分配给需要快速存储的应用程序使用的池，而将带有传统hdd的osd分配给支持要求较低的工作负载的池

CRUSH map可以包含多个层次结构，你可以通过不同的CRUSH规则进行选择。
通过使用单独的CRUSH层次结构，可以建立单独的性能域。
配置单独性能域的用例示例如下：

1. 分离虚拟机使用的块存储和应用使用的对象存储

2. 将包含不经常访问的数据的“冷”存储区与包含经常访问的数据的“热”存储区分开

如果检查一个实际的CRUSH map定义，它包含：

1. 所有可用物理存储设备的列表

2. 所有基础设施桶的列表，以及每个桶中存储设备或其他桶的id。请记住，bucket是基础结构树中的容器或分支，例如，它可能表示一个位置或一块物理硬件

3. 将pg映射到osd的CRUSH规则列表

4. 其他CRUSH可调参数及其设置的列表

集群安装过程部署一个默认的CRUSH映射，可以使用ceph osd crush dump命令打印JSON格式的crush map。你也可以导出映射的二进制副本，并将其反编译为文本文件:

```bash
[ceph: root@node /]# ceph osd getcrushmap -o ./map.bin 
[ceph: root@node /]# crushtool -d ./map.bin -o ./map.txt 
```

##### 自定义OSD CRUSH设置

CRUSH映射包含集群中所有存储设备的列表。对于每台存储设备，已获取如下信息:

1. 存储设备的ID

2. 存储设备的名称

3. 存储设备的权重，通常以tb为单位。
   例如，4tb的存储设备重量约为4.0。这是设备可以存储的相对数据量，CRUSH算法使用这一数据来帮助确保对象的均匀分布

可以通过ceph osd crush reweight命令设置OSD的权重。CRUSH的树桶权重应该等于它们的叶子权重的总和。
如果手动编辑CRUSH映射权重，那么应该执行以下命令来确保CRUSH树桶的权重准确地反映了桶内叶片osd的总和

```bash
[ceph: root@node /)# ceph osd crush reweight-all 
reweighted crush hierarchy
```

4. 存储设备的类别，存储集群支持多种存储设备，如hdd、ssd、NVMe ssd等。
   存储设备的类反映了这些信息，可以使用这些信息创建针对不同应用程序工作负载优化的池。
   osd自动检测和设置它们的设备类。[ceph osd crush set- device-class]()命令用于显式设置OSD的设备类。
   使用[ceph osd crush rm device-class]()从osd中删除一个设备类

ceph osd crush tree命令显示crush map 当前的层级：

```bash
[ceph: root@clienta /]# ceph osd crush tree 
ID  CLASS  WEIGHT   TYPE NAME       
-1         0.08817  root default    
-3         0.02939      host serverc
 0    hdd  0.00980          osd.0   
 1    hdd  0.00980          osd.1   
 2    hdd  0.00980          osd.2   
-5         0.02939      host serverd
 3    hdd  0.00980          osd.3   
 5    hdd  0.00980          osd.5   
 7    hdd  0.00980          osd.7   
-7         0.02939      host servere
 4    hdd  0.00980          osd.4   
 6    hdd  0.00980          osd.6   
 8    hdd  0.00980          osd.8   
```

设备类是通过为每个正在使用的设备类创建一个“影子”CRUSH层次结构来实现的，它只包含该类设备。
然后，CRUSH规则可以在影子层次结构上分发数据。
你可以使用ceph osd crush tree --show-shadow命令查看带有影子的crush 层级

使用ceph osd crush class create命令创建一个新的设备类

使用ceph osd crush class rm命令删除一个设备类

使用ceph osd crush class ls命令列出已配置的设备类

##### 使用CRUSH规则

CRUSH map还包含数据放置规则，决定如何将pg映射到osd，以存储对象副本或erasure coded块，ceph osd crush rule ls命令在已有的规则基础上，打印规则详细信息。ceph osd crush rule dump rule_name命令打印规则详细信息，编译后的CRUSH map也包含规则，可能更容易阅读:

```bash
[ceph: root@node /]# ceph osd getcrushmap -o . /map.bin 
[ceph: root@node /]# crushtool -d . /map.bin -o . /map.txt 
[ceph: root@node /]# cat . /map.txt 
. . . output omitted ... 
rule replicated_rule { AA
id 0 BB 
} 
type replicated 
min_size 1 CC
max_size 10 DD 
step take default EE 
step chooseleaf firstn 0 type host FF 
step emit GG
. . . output omitted ...
```

AA 规则的名称。使用[ceph osd pool create]()命令创建池时，使用此名称来选择规则

BB 规则ID。有些命令使用规则ID而不是规则名称。例如:[ceph osd pool set pool-name rush_ruleset ID]()，为已存在的池设置规则时使用规则ID

CC 如果一个池的副本数少于这个数字，那么CRUSH不选择此规则

DD 如果一个存储池的副本数超过这个数字，那么CRUSH不选择此规则

EE 接受一个桶名，并开始沿着树进行迭代。
在本例中，迭代从名为default的桶开始，它是缺省CRUSH层次结构的根。
对于由多个数据中心组成的复杂层次结构，可以为数据创建规则，用于强制将特定池中的对象存储在该数据中心的osd中。
在这种情况下，这个步骤可以从数据中心桶开始迭代

FF 选择给定类型(host)的桶集合，并从该集合中每个桶的子树中选择一个叶子(OSD)。
本例中，规则从集合中的每个主机桶中选择一个OSD，确保这些OSD来自不同的主机。
集合中桶的数量通常与池中的副本数量(池大小)相同:

1.  如果firstn后面的数字为0，则根据池中有多少副本选择多少桶

2.  如果桶的数量大于零，且小于池中的副本数量，则选择相同数量的桶。
    在这种情况下，规则需要另一个步骤来为剩余的副本绘制桶。
    可以使用这种机制强制指定对象副本子集的位置

3. 如果这个数字小于零，那么从副本数量中减去它的绝对值，然后选择这个数量的桶

GG 输出规则的结果

例如，可以创建以下规则来在不同的机架上选择尽可能多的osd，但只能从DC1数据中心:

```bash
rule myrackruleinDC1 { 
      id 2 
      type replicated
           min_size 1 
           max_size 10 
           step take DC1
           step chooseleaf firstn 0 type rack 
           step emit
}
```

##### 使用CRUSH可调参数

还可以使用可调参数修改CRUSH算法的行为。
可调项可以调整、禁用或启用CRUSH算法的特性。
Ceph在反编译的CRUSH映射的开始部分定义了可调参数，你可以使用下面的命令获取它们的当前值:

```bash
[ceph: root@clienta /]# ceph osd crush show-tunables
{
    "choose_local_tries": 0,
    "choose_local_fallback_tries": 0,
    "choose_total_tries": 50,
    "chooseleaf_descend_once": 1,
    "chooseleaf_vary_r": 1,
    "chooseleaf_stable": 1,
    "straw_calc_version": 1,
    "allowed_bucket_algs": 54,
    "profile": "jewel",
    "optimal_tunables": 1,
    "legacy_tunables": 0,
    "minimum_required_version": "jewel",
    "require_feature_tunables": 1,
    "require_feature_tunables2": 1,
    "has_v2_rules": 0,
    "require_feature_tunables3": 1,
    "has_v3_rules": 0,
    "has_v4_buckets": 1,
    "require_feature_tunables5": 1,
    "has_v5_rules": 0
}
```

调整CRUSH可调项可能会改变CRUSH将放置组映射到osd的方式。
当这种情况发生时，集群需要将对象移动到集群中的不同osd，以反映重新计算的映射。
在此过程中，集群性能可能会下降。

可以使用[ceph osd crush tunables profile]() 命令选择一个预定义的配置文件，而不是修改单个可调项。
将配置文件的值设置为optimal，以启用Red Hat Ceph Storage当前版本的最佳(最优)值。

#### 5.1.3 CRUSH Map 管理

集群保持一个编译后的CRUSH map的二进制表示。你可以通过以下方式修改它:

1. 使用[ceph osd crush]()命令

2. 提取二进制CRUSH映射并将其编译为纯文本，编辑文本文件，将其重新编译为二进制格式，然后将其导入到集群中

通常使用ceph osd crush命令更新CRUSH地图会更容易。
但是，还有一些不太常见的场景只能通过使用第二种方法来实现。

##### 使用Ceph命令定制CRUSH地图

下面的例子创建了一个新的桶:

```bash
[ceph: root@node /]# ceph osd crush add-bucket name type 
```

例如，这些命令创建三个新桶，一个是数据中心类型，两个是机架类型:

```bash
[ceph: root@node /)# ceph osd crush add-bucket DC1 datacenter 
added bucket DCl type datacenter to crush map 
[ceph: root@node /)# ceph osd crush add-bucket rackA1 rack 
added bucket rackAl type rack to crush map 
[ceph: root@node /)# ceph osd crush add-bucket rackB1 rack 
added bucket rackBl type rack to crush map
```

然后，可以使用以下命令以层次结构组织新桶

```bash
[ceph: root@node /]# ceph osd crush move name type=parent
```

还可以使用此命令重新组织树。例如，将上例中的两个机架桶挂载到数据中心桶上，将数据中心桶挂载到默认的根桶上

```bash
[ceph: root@node /]# ceph osd crush move rackA1 datacenter=DC1 
moved item id -10 name ' rackA1' to location {datacenter=DCl} in crush map 
[ceph: root@node /]# ceph osd crush move rackB1 datacenter=DC1 
moved item id -11 name ' rackB1' to location {datacenter=DC1} in crush map 
[ceph: root@node /)# ceph osd crush move DC1 root=default 
moved item id -9 name ' DC1' to location {root=default} in crush map
```

##### 设置osd位置

在创建了自定义桶层次结构之后，将osd作为该树的叶子放置。
每个OSD都有一个位置，它是一个字符串，定义从树的根到该OSD的完整路径。

例如，挂在rackA1桶上的OSD的位置为:

```bash
root=default datacenter=DC1 rack=rackA1
```

当Ceph启动时，它使用ceph-crush-location工具来自动验证每个OSD都在正确的CRUSH位置。
如果OSD不在CRUSH地图中预期的位置，它将被自动移动。
默认情况下，这是root=default host=hostname。

可以用自己的脚本替换ceph-crush-location实用程序，以更改osd在CRUSH地图中的位置。
为此，在/etc/ceph/ceph.conf中指定crush_ location_hook参数

```ini
[osd] 
crush_location_hook = /path/to/your/script
```

Ceph使用以下参数执行该脚本: --cluster cluster-name --id osd-id --type osd。
脚本必须在其标准输出中以一行的形式打印位置。
上游Ceph文档有一个自定义脚本示例，该脚本假设每个系统都有一个名为/etc/rack的包含所在机架名称的机架文件:

```bash
#! /bin/sh 
echo "root=default rack=$(cat /etc/rack) host=$(hostname -s)"
```

可以在/etc/ceph/ceph.conf中设置crush_ location参数。
重新定义特定osd的位置。
例如，设置osd.0和osd.1，在文件中各自的部分中添加crush_ location参数:

```bash
[osd.0] 
crush_location = root=default datacenter=DC1 rack=rackA1 
[osd.1] 
crush_location = root=default datacenter=DC1 rack=rackB1 
```

##### 添加CRUSH Map规则

这个例子创建了一个Ceph可以用于复制池的规则:

```bash
[ceph: root@node /]# ceph osd crush rule create-replicated name root failure-domain-type [class]
```

其中:

1. Name为规则的名称

2. root是CRUSH地图层次结构中的起始节点

3. failure-domain-type是用于复制的桶类型

4. 类是要使用的设备的类，例如SSD或hdd。可选参数

下面的示例创建新的inDC2规则来在DC2数据中心存储副本，将副本分发到各个机架:

```bash
[ceph: root@node /]# ceph osd crush rule create-replicated inDC2 DC2 rack 
[ceph: root@node /]# ceph osd crush rule ls 
replicated_rule 
erasure-code 
inDC2 
```

定义规则后，在创建复制池时使用它:

```bash
[ceph: root@node /]# ceph osd pool create myfirstpool 50 50 inDC2 
pool 'myfirstpool' created
```

对于erasure code，Ceph自动为您创建的每个erasure code池创建规则。
规则的名称为新池的名称。
Ceph使用您在创建池时指定的erasure code配置文件中定义的规则参数。

下面的例子首先创建新的myprofile erasure code配置文件，然后基于这个配置文件创建myecpool池:

```bash
[ceph: root@node /]# ceph osd erasure-code-profile set myprofile \
	k=2 m=1 crush-root=DC2 crush-failture-domain=rack crush-device-class=ssd 
[ceph: root@node /)# ceph osd pool create myecpool 50 50 erasure myprofile 
[ceph: root@node /]# ceph osd crush rule ls
```

##### 通过编译二进制版本自定义CRUSH地图

你可以用以下命令来反编译和手动编辑CRUSH地图:

|                   命令                   | 动作                                            |
| :--------------------------------------: | ----------------------------------------------- |
|   [ceph osd getcrushmap -o binfiIe]()    | 导出当前映射的二进制副本                        |
| [crushtool -d binfiIe -o textfiIepath]() | 将一个CRUSH映射二进制文件反编译成一个文本文件   |
| [crushtool -c textfiIepath -o binfiIe]() | 从文本中编译一个CRUSH地图                       |
|     [crushtool -i binfiIe --test]()      | 在二进制CRUSH地图上执行演练，并模拟放置组的创建 |
|   [ceph osd setcrushmap -i binfiIe]()    | 将二进制CRUSH映射导入集群                       |

[ceph osd getcrushmap]()和[ceph osd setcrushmap]()命令提供了一种备份和恢复集群CRUSH地图的有效方法

#### 5.1.4 优化放置组

放置组(pg)允许集群通过将对象聚合到组中以可伸缩的方式存储数百万个对象。
根据对象的ID、池的ID和池中放置组的数量将对象组织成放置组。
在集群生命周期中，pg个数需要根据集群布局的变化进行调整

CRUSH试图确保对象在池中osd之间的均匀分布，但也存在pg变得不平衡的情况。
放置组自动缩放器可用于优化PG分发，并在默认情况下打开。
如果需要，还可以手动设置每个池的pg数量

对象通常是均匀分布的，前提是池中比osd多一个或两个数量级(十个因子)的放置组。
如果没有足够的pg，那么对象的分布可能会不均匀。
如果池中存储了少量非常大的对象，那么对象分布可能会变得不平衡

应该配置pg，以便有足够的对象在集群中均匀分布。
如果pg的数量设置过高，则会显著增加CPU和内存的使用。
Red Hat建议每个OSD大约100到200个放置组来平衡这些因素

##### 计算放置组的数量

对于单个池的集群，可以使用以下公式，每个OSD 100个放置组

```bash
Total PGs = (OSDs * 100)/Number of replicas 
```

Red Hat推荐使用每个池计算Ceph放置组，https://access.redhat.com/labs/cephpgc/manual/

##### 手动映射PG

使用[ceph osd pg-upmap-iterns]()命令手动将pg映射到指定的osd，因为以前的Ceph客户端不支持，所以必须配置[ceph osd set-require-min-compat-client]()启用pg-upmap命令

```bash
[ceph: root@node /]# ceph osd set-require-min-compat-client luminous
```

下面的例子将PG 3.25从ODs 2和0映射到1和0:

```bash
[ceph: root@node /]# ceph pg map 3.25 
osdmap e384 pg 3.25 (3.25) -> up [2,0) acting [2,0) 
[ceph: root@node /]# ceph osd pg-upmap-items 3.25 2 1 
set 3.25 pg_ upmap items mapping to [2->1) 
[ceph: root@node /]# ceph pg map 3.25 
osdmap e387 pg 3.25 (3.25) •> up [1,0) acting [1,0)
```

以这种方式重新映射数百个pg是不现实的。
osdmaptool命令在这里很有用，它获取一个池的实际地图，分析它，并生成ceph osd pg-upmap-items命令来运行一个最优分布:

1. 将映射导出到一个文件，下面的命令将映射保存到./om文件:

```bash
[ceph: root@node /]# ceph osd getmap -o ./om 
got osdmap epoch 387 
```

2. 使用osdmaptool命令的--test-map-pgs选项显示pg的实际分布。打印ID为3的池的分布信息:

```bash
[ceph: root@node /]# osdmaptool ./om --test-map-pgs --pool 3 
osdmaptool: osdmap file './om' 
pool 3 pg_num 50 
#osd count first primary c wt wt 
osd.0 34 19 19 0.0184937 1 
osd.1 39 14 14 0.0184937 1 
osd.2 27 17 17 0.0184937 1 
... output omitted . .. 
```

输出显示了osd.2只有27个PG而osd.1有39 PG

3. 生成重新平衡pg的命令。
   使用osdmaptool命令的--upmap选项将命令存储在一个文件中:

```bash
[ceph: root@node /]# osdmaptool ./om --upmap ./cmds.txt --pool 3 
osdmaptool: osdmap file './om' 
writing upmap command output to: ./cmds.txt 
checking for upmap cleanups 
upmap, max-count 100, max deviation 0.01 
[ceph: root@node /]# cat ./cmds.txt 
ceph osd pg-upmap-items 3.1 0 2 
ceph osd pg-upmap-items 3.3 1 2 
ceph osd pg-upmap-items 3.6 0 2 
... output omitted ... 
```

4. 执行命令:

```bash
[ceph: root@node /]# bash ./cmds.txt 
set 3.1 pg upmap items mapping to [0->2] 
set 3.3 pg upmap_items mapping to [1->2] 
set 3.6 pg_upmap_items mapping to [0->2] 
... output omitted ...
```

### 5.2 管理OSD Map

#### 5.2.1 描述OSD地图

集群OSD map包含每个OSD的地址、状态、池列表和详细信息，以及OSD的接近容量限制信息等。
Ceph使用这些最后的参数来发送警告，并在OSD达到满容量时停止接受写请求

当集群的基础设施发生变化时，比如osd加入或离开集群，MONs会相应地更新相应的映射。
Mons保持着map修订的历史。
Ceph使用一组被称为epoch的有序增量整数来标识每个map的每个版本

[ceph status -f json-pretty]()命令显示每个map的epoch。
使用[ceph map dump]()子命令显示每个单独的映射，例如ceph osd dump

```bash
[ceph: root@clienta /]# ceph status -f json-pretty

{
    "fsid": "2ae6d05a-229a-11ec-925e-52540000fa0c",
    "health": {
        "status": "HEALTH_OK",
        "checks": {},
        "mutes": []
    },
    "election_epoch": 48,
    "quorum": [
        0,
        1,
        2,
        3
    ],
    "quorum_names": [
        "serverc.lab.example.com",
        "clienta",
        "serverd",
        "servere"
    ],
    "quorum_age": 1961,
    "monmap": {
        "epoch": 4,
        "min_mon_release_name": "pacific",
        "num_mons": 4
```

#### 5.2.2 分析OSD Map更新

每当有OSD加入或离开集群时，Ceph都会更新OSD的map。
一个OSD可以因为OSD故障或硬件故障而离开Ceph集群

虽然整个集群map是由MONs维护的，但是OSD并不使用leader来管理OSD map;他们在彼此之间传播map。
OSD将他们与OSD map时期交换的每条消息都标记出来。
当一个OSD检测到自己的运行速度落后时，将会触发对其对等OSD执行map更新

在大的集群中，OSD map更新频繁，所以总是分发完整的map是不现实的。
相反，接收OSD的节点执行增量映射更新

Ceph还将osd和客户端之间的消息标记为epoch。
每当客户端连接到OSD时，OSD就会检查epoch。
如果epoch不匹配，那么OSD将响应正确的增量，以便客户机可以更新其OSD映射。
这就不需要主动传播，因为客户端只有在下一次联系时才会了解更新后的映射

##### 使用Paxos更新集群Map

要访问Ceph集群，客户机首先要从MONs获取集群映射的副本。
为了使集群正常运行，所有的MONs必须具有相同的集群映射。

MONs使用Paxos算法作为一种机制来确保它们对集群状态达成一致。

Paxos是一种分布式共识算法。
每当MON修改map时，它就通过Paxos将更新发送给其他监视器。
Ceph只有在大多数监控器都同意更新后才会提交新版本的map。

MON向Paxos提交map更新，只有在Paxos确认更新后才将新版本写入本地键值存储。
读操作直接访问键值存储。

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/map/map-osd-paxos.svg)

##### 传播OSD地图

osd定期向监控器报告其状态。
此外，OSD还可以通过交换心跳来检测对等体的故障，并将故障报告给监视器。

当leader监视器得知OSD出现故障时，它会更新Map，增加epoch，并使用Paxos更新协议通知其他监视器，同时撤销它们的租约。
在大多数监控器确认更新后，集群有了仲裁，leader监控器发出新的租约，以便监控器可以分发更新的OSD映射。
这种方法避免了映射纪元在集群中的任何位置向后移动，也避免了查找以前仍然有效的租约。

OSD Map命令管理员使用以下命令管理OSD Map:

|                        命令                        | 动作                               |
| :------------------------------------------------: | ---------------------------------- |
|                 [ceph osd dump]()                  | 将OSD映射转储到标准输出            |
|           [ceph osd getmap -o binfile]()           | 导出当前映射的二进制副本           |
|           [osdmaptool --print binfile]()           | 在标准输出中显示人类可读的映射副本 |
| [osdmaptool --export-crush crushbinfile binfile]() | 从OSD map 中提取CRUSH map          |
| [osdmaptool --import-crush crushbinfile binfile]() | 嵌入一个新的CRUSH map              |
|     [osdmaptool --test-map-pg pgid binfile]()      | 验证给定PG的映射                   |



## 6. 使用 RADOS 块设备提供块存储

### 6.1 管理RADOS块设备

#### 6.1.1 基于RBD的块存储

块设备是服务器、笔记本电脑和其他计算系统最常见的长期存储设备。
它们将数据存储在固定大小的块中。
块设备包括基于旋转磁碟的硬盘驱动器和基于非易失性存储器的固态驱动器。
要使用存储，请使用文件系统格式化块设备，并将其挂载到Linux文件系统层次结构上

RBD (RADOS Block Device)特性提供来自Red Hat Ceph存储集群的块存储。
RADOS在Red Hat Ceph存储集群的池中提供了存储为RBD映像的虚拟块设备

#### 6.1.2 管理和配置RBD镜像

作为存储管理员，可以使用rbd命令创建、列表、检索块设备镜像信息、调整大小和移除块设备镜像。
创建RBD镜像的示例如下:

1. 确保rbd映像的rbd池(或自定义池)存在。
   使用[ceph osd pool create]()命令创建RBD镜像池。
   创建完成后，需要使用rbd pool init命令对其进行初始化

2. 虽然Ceph管理员可以访问池，但Red Hat建议您使用Ceph auth命令为客户端创建一个更受限制的Cephx用户。
   授予用户只对需要的RBD池进行读写访问，而不是访问整个集群

3. 使用[rbd create - -size SIZE pooI-name/image-name]()命令创建RBD镜像。
   如果不指定存储池名称，则使用默认的存储池名称

rbd_defaultlt_pool参数指定用于存储RBD映像的默认池的名称。
使用[ceph config set osd rbd_default pool value]()设置该参数

#### 6.1.3 访问RADOS块设备存储

内核RBD客户端(krbd)将RBD映像映射到Linux块设备。
librbd库为KVM虚拟机和OpenStack云实例提供RBD存储。
这些客户机允许裸机服务器或虚拟机使用RBD映像作为普通的基于块的存储。
在OpenStack环境中，OpenStack将这些RBD映像附加并映射到Linux服务器，它们可以作为启动设备。
Red Hat Ceph Storage 将虚拟块设备使用的实际存储分散到整个集群中，通过IP网络提供高性能访问

##### 使用RBD内核客户端访问Ceph存储

Ceph客户端可以使用本地Linux内核模块krbd挂载RBD映像。
这个模块将RBD映像映射到名称为/dev/rbd0的Linux块设备

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/devices-access-rbd-kernel.svg)

rbd device map命令使用krbd内核模块来映射一个image。
rbd map命令是rbd device map命令的缩写。
rbd device unmap (rbd unmap)命令使用krbd内核模块解除映射的镜像。
将RBD池中的test RBD镜像映射到客户端主机上的/dev/rbd0设备

```bash
[root@node ~]# rbd map rbd/test 
/dev/rbd0 
```

Ceph客户端系统可以像其他块设备一样使用映射的块设备(在示例中称为/dev/rbd0)。
可以使用文件系统对其进行格式化、挂载和卸载

两个客户端可以同时将同一个RBD映像映射为一个块设备。
这对于备用服务器的高可用性集群非常有用，但是Red Hat建议当块设备包含一个普通的单挂载文件系统时，一次将一个块设备附加到一个客户机上。
同时在两个或多个客户机上挂载包含普通文件系统(如XFS)的RADOS块设备可能会导致文件系统损坏和数据丢失

rbd device list命令，缩写为rbd showmapped，用来列出机器上映射的rbd映像

```bash
[root@node -)# rbd showmapped 
id pool namespace image snap device
0  rbd             test  -    /dev/rbd0
```

rbd device unmap命令，缩写为rbd unmap，用于从客户端机器上解除rbd映像的映射

```bash
[root@node ~]# rbd unmap /dev/rbd0
```

rbd map和rbd unmap命令需要root权限

##### 持久化映射RBD图像

rbdmap服务可以在启动和关闭系统时自动将RBD映像映射和解除映射到设备。
/etc/ceph/rbdmap中查找具有其凭证的映射图像，服务使用它们在/etc/fstab文件中显示的挂载点来挂载和卸载RBD映像

以下步骤将rbdmap配置为持久化映射和解除映射一个已经包含文件系统的RBD映像:

1. 为文件系统创建挂载点

2. 在/etc/ceph/rbdmap RBD映射文件中创建一个单行条目。
   这个条目必须指定RBD池和映像的名称。
   它还必须引用具有读写权限的Cephx用户来访问映像和相应的密钥环文件。
   确保客户端系统上存在用于Cephx用户的key-ring文件

3. 在客户端系统的/etc/fstab文件中为RBD创建一个条目。
   块设备的名称形式如下:

```bash
/dev/rbd/pool_name/image_name
```

​			指定noauto挂载选项，因为处理文件系统挂载的是rbdmap服务，而不是Linux fstab例程

4. 确认块设备映射成功。使用rbdmap map命令挂载设备。使用rbdmap unmap命令卸载

5. 启用rbdmap systemd服务，有关更多信息，请参阅rbdmap(8)

##### 使用基于librbd的客户端访问Ceph存储

librbd库为用户空间应用程序提供了对RBD映像的直接访问。
它继承了librados将数据块映射到Ceph对象存储中的对象的能力，并实现了访问RBD映像以及创建快照和克隆的能力

云和虚拟化解决方案，如OpenStack和libvirt，使用librbd将RBD映像作为块设备提供给云实例和它们管理的虚拟机。
例如，RBD映像可以存储QEMU虚拟机映像。
使用RBD克隆特性，虚拟容器可以在不复制引导映像的情况下引导虚拟机。
当写入克隆内未分配的对象时，copy-on-write (COW)机制将数据从父复制到克隆。
读取时复制(COR)机制从克隆内未分配的对象读取数据时，将数据从父克隆复制到克隆

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/devices-access-rbd-vm.svg)

因为Ceph块设备的用户空间实现(例如，librbd)不能利用Linux页面缓存，所以它执行自己的内存缓存，称为RBD缓存。
RBD缓存的行为与Linux)页面缓存的方式类似。
当OS实现一个barrier机制或一个flush请求时，Ceph将所有脏数据写入osd。
这意味着使用回写缓存与在虚拟机中使用物理硬盘缓存(例如，Linux内核>= 2.6.32)一样安全。
缓存使用最近最少使用(LRU)算法，在回写模式下，它可以合并连续的请求以获得更好的吞吐量

RBD缓存对于客户机来说是本地的，因为它使用发起I/O请求的机器上的RAM。
例如，如果你的redhat OpenStack平台安装的Nova计算节点使用librbd作为虚拟机，OpenStack客户端启动I/O请求将使用本地RAM作为RBD缓存

##### RBD缓存配置

- **缓存未启用**
  读取和写入到Ceph对象存储。
  Ceph集群在所有相关OSD日志上写入和刷新数据时承认写入操作

- **缓存启用(回写式)**
  考虑两个值，未刷新的缓存字节数U和最大脏缓存字节数M，当U < M时，或者在将数据写回磁盘直到U < M时，才承认写操作

- **直写式高速缓存**
  将最大脏字节设置为O以强制透写模式。
  Ceph集群在所有相关OSD日志上写入和刷新数据时承认写入操作

如果使用回写模式，那么当librbd库将数据写入服务器的本地缓存时，它会缓存并承认I/O请求。
考虑对战略生产服务器进行透写，以减少服务器故障时数据丢失或文件系统损坏的风险。
Red Hat Ceph Storage提供了以下一组RBD缓存参数:

|                参数                | 描述                                        | 默认  |
| :--------------------------------: | ------------------------------------------- | :---: |
|             rbd_cache              | 启用RBD缓存，Value=true I false             | true  |
|           rbd_cache_size           | 每个RBD的缓存大小，单位为字节               | 32 MB |
|        rbd_cache_ max_dirty        | 每个RBD映像允许的最大脏字节                 | 24 MB |
|       rbd_cache_target_dirty       | 每个RBD镜像启动抢占式刷写的脏字节           | 16 MB |
|      rbd_cache_max_dirty_age       | 刷写前的最大页寿命(以秒为单位)              |   1   |
| rbd_cache_writethrough_until_flush | 从write-through模式开始，直到执行第一次刷新 | true  |

分别执行ceph config set client parameter value命令或ceph config set global parameter value命令

使用librbd时，需要为OpenStack Cinder、Nova和Glance分别创建单独的Cephx用户名。
通过遵循推荐的实践，您可以根据Red Hat OpenStack平台环境访问的RBD映像类型创建不同的缓存策略

#### 6.1.4 调整RBD镜像格式

RBD镜像在对象上条带化，并存储在RADOS对象存储中。
Red Hat Ceph Storage提供了定义这些镜像如何条纹化的参数

##### RADOS块设备镜像布局

RBD镜像中的所有对象都有一个名称，以每个RBD镜像的“RBD Block name Prefix”字段的值开头，通过RBD info命令显示。
在这个前缀之后，有一个句点(.)，后面跟着对象编号。对象编号字段的值是一个12个字符的十六进制数

```bash
[root@node ~]# rbd info rbdimage 
rbd image rbdimage: 
size 10240{nbsp}MB in 2560 objects 
order 22 (4 MiB objects) 
snapshot_ count: 0 
id: 867cba5c2d68 
block_name_prefix: `rbd_data.867cba5c2d68`
format: 2 
features: layering, exclusive-lock, object-map, fast-diff, deep-flatten 
```

```bash
[root@node -]# rados -p rbd ls 
rbd_object_map.d3d0d7d0b79e.0000000000000008 
rbd_id.rbdimage 
rbd_object_map.d42cle0al883 
rbd_directory 
rbd_children 
rbd_info 
rbd_header.d3d0d7d0b79e 
rbd_header.d42cle0al883 
rbd_object_map.d3d0d7d0b79e 
rbd_trash 
```

Ceph块设备支持在一个红帽Ceph存储集群内的多个OSD上条带化存储数据

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/devices-rbd-layout.svg)

##### RBD镜像顺序

镜像顺序是RBD镜像中使用的对象的大小。
镜像顺序基于<<(bitwise left shift)C操作符定义一个二值移位值。
该操作符将左操作数位移位右操作数值。
例如:1 << 2 = 4。十进制1是二进制的0001，因此1 << 2 = 4运算的结果是二进制的0100，即十进制的4。
镜像顺序的值必须在12到25之间，其中12 = 4 KiB, 13 = 8 KiB。为例。默认镜像顺序为22，产生4个MiB节点。
可以使用rbd create命令的--order选项来覆盖缺省值

你可以用--object-size选项指定对象的大小。
该参数指定的对象大小必须在4096 (4kib) ~ 33,554,432 (32mib)之间，单位为字节/ K或M(如4096、8k或4m)

##### RBD镜像格式

每个RBD镜像都有三个相关参数:

- **image_format** RBD镜像格式版本。默认值为2，即最新版本。
  版本1已被弃用，不支持克隆和镜像等特性

- **stripe_unit** 一个对象中存储的连续字节数，默认为object_size。

- **stripe_count** 条带跨越的RBD映像对象数目，默认为1

对于RBD格式2镜像，可以更改每个参数的值。设置必须与下列等式对齐:

```bash
stripe_unit * stripe_count = object_size
```

For example:

```bash
stripe_unit = 1048576, stripe_count = 4 for default 4 MiB objects
```

记住object_size必须不小于4096字节，且不大于33,554,432字节。
当你创建RBD映像时，使用--object-size选项指定这个值。
缺省情况下，节点大小为4192304字节(4mib)

### 6.2 管理RADOS块设备快照

#### 6.2.1 启用RBD快照和克隆功能

使用RBD格式2的镜像支持几个可选特性。
请使用rbd feature enable或rbd feature disable命令开启或关闭rbd镜像特性。
这个例子在rbd池中的测试图像上启用了分层特性

```bash
[root@node ~]# rbd feature enable rbd/test layering 
```

禁用分层特性，使用rbd feature disable命令:

```bash
[root@node ~]# rbd feature disable rbd/test layering
```

这些是RBD镜像的一些可用特性;

|      名称      | 描述                                                |
| :------------: | --------------------------------------------------- |
|    layering    | 分层支持以启用克隆                                  |
|    striping    | Striping v2支持增强性能，用librbd支持               |
| exclusive-lock | 独占锁定的支持                                      |
|   object-map   | 对象映射支持(需要独占锁)                            |
|   fast-diff    | 快速diff命令支持(需要object-map AND exclusive-lock) |
|  deep-flatten  | 扁平化RBD映像的所有快照                             |
|   journaling   | 日志记录                                            |
|   data- pool   | EC数据池支持                                        |

#### 6.2.2 RBD 快照

RBD快照是在特定时间创建的RBD映像的只读副本。
RBD快照使用COW技术来减少维护快照所需的存储空间。
当集群对RBD快照镜像发起写I/O请求时，需要先将原始数据复制到该RBD快照镜像所在位置组的其他区域。
快照在创建时不消耗任何存储空间，而是随着它们所包含的对象的大小而增长改变。
RBD映像支持增量快照

在创建快照之前，使用fsfreeze命令暂停对文件系统的访问。
fsfreeze --freeze命令停止对文件系统的访问，并在磁盘上创建一个稳定的映像。
当文件系统未冻结时，不要进行文件系统快照，因为这会破坏快照的文件系统。
快照完成后，使用fsfreeze - -unfreeze命令恢复对文件系统的操作和访问

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/device-snapshot01.svg)

快照COW过程在对象级别操作，与RBD映像的写I/O请求的大小无关。
如果您向具有快照的RBD映像写入单个字节，那么Ceph将整个受影响的对象从RBD映像复制到快照区域

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/device-snapshot02.svg)

如果RBD镜像存在快照，则删除RBD镜像失败。
使用rbd snap purge命令删除快照

使用rbd snap create命令创建Ceph设备的快照

```bash
[root@node ~]# rbd snap create pool/image@firstsnap 
creating snap: 100% complete ... done.
```

使用rbd snap ls命令列出块设备快照

```bash
[root@node -]# rbd snap ls pool/image 
SNAPID NAME         SIZE         PROTECTED TIMESTAMP 
4     firstsnap     128 MiB     Thu Oct 14 16:55:01 2021 
7     secondsnap    128 MiB     Thu Oct 14 17:48:59 2021 
```

rbd snap rollback命令用于回滚块设备快照，快照中的数据将覆盖当前镜像版本

```bash
[root@node ~]# rbd snap rollback pool/image@firstsnap 
SNAPID     NAME         SIZE     PROTECTED TIMESTAMP 
4         firstsnap     128 MiB  Thu Oct 14 16:55:01 2021 
7         secondsnap    128 MiB  Thu Oct 14 17:48:59 2021 

```

使用rbd snap rm命令删除Ceph块设备的快照

```bash
[root@node ~]# rbd snap rm pool/image@secondsnap 
Removing snap: 100% complete ... done
```

#### 6.2.3 RBD 克隆

RBD克隆是以RBD受保护快照为基础的RBD镜像的读写副本。
RBD克隆也可以被扁平化，这可以将其转换为独立于源的RBD映像。
克隆过程有三个步骤:

1. 创建一个快照
   
   ```bash
   [root@node ~]# rbd snap create poollimage@snapshot 
   Creating snap: 100% complete ... done.
   ```

2. 保护快照不被删除
   
   ```bash
   [root@node ~]# rbd snap protect pool/image@snapshot 
   ```

3. 使用受保护快照创建克隆
   
   ```bash
   [root@node ~]# rbd clone poollimagename@snapshotname poollclonename 
   ```

新创建的克隆的行为就像一个常规的RBD映像。
克隆支持COW和COR，默认为COW。
COW向克隆应用写I/O请求之前，先将父快照数据拷贝到克隆中

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/device-clone01.svg)

可以因此启用COR支持RBD克隆。
与父RBD快照和克隆快照相同的数据直接从父RBD快照读取。
如果父节点的osd相对于客户端有较高的延迟，这可能会使读取更昂贵。
COR将对象第一次读取时复制到克隆

如果启用了COR, Ceph会在处理读I/O请求之前将数据从父快照复制到克隆中，如果数据还没有出现在克隆中。
通过运行ceph config set client rbd_c lone_copy_on_read true命令或ceph config set global rbd_clone_copy_on_read true命令来激活COR特性，不覆盖原始数据

如果在RBD克隆上禁用了COR，克隆不能满足的每一个读操作都会向克隆的父节点发出I/O请求

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/device-clone02.svg)

克隆COW和COR过程在对象级操作，不管请求大小是I/O。要读取或写入RBD克隆的单个字节，Ceph将整个对象从父映像或快照复制到克隆中

使用rbd命令管理rbd克隆

|                             命令                             | 描述       |
| :----------------------------------------------------------: | ---------- |
|    [rbd children [pool-name/]image-name@snapshot-name]()     | 列出克隆   |
| [rbd clone [pool-name/]parent-image@snap-name [pool-name/]child-image-name]() | 创建克隆   |
|         [rbd flatten [pool-namel]child-image-name]()         | 扁平化克隆 |

当扁平化一个克隆时，Ceph将所有缺失的数据从父副本复制到克隆中，然后删除对父副本的引用。
克隆将成为一个独立的RBD映像，并且不再是受保护快照的子快照, 不能直接从池中删除RBD映像。
相反，使用[rbd trash mv]()命令将映像从池中移动到垃圾中。
使用[rbd trash rm]()命令从垃圾中删除对象。
可以将克隆正在使用的活动映像移动到垃圾中，以便稍后删除

### 6.3 导入和导出RBD镜像

#### 导入和导出RBD镜像

RBD导出和导入机制允许维护RBD映像的可操作副本，在同一个集群中或通过使用单独的集群实现功能完整且可访问的。
可以将这些副本用于各种用例，包括:

1. 使用真实的数据量测试新版本

2. 使用真实的数据量运行质量保证流程

3. 使用真实的数据量实现业务连续性场景

4. 将备份流程与生产块设备解耦

RADOS块设备特性提供了导出和导入整个RBD映像或仅RBD映像在两个时间点之间变化的能力

#### 导出RBD镜像

Red Hat Ceph Storage提供了rbd export命令来导出rbd镜像到文件中。
该命令将RBD镜像或RBD镜像快照导出到指定的目标文件中。rbd export命令的语法如下:

```bash
rbd export [--export-format {1|2}) (image-spec | snap-spec) [dest-path] 
```

--export-format选项指定导出数据的格式，允许将较早的RBD格式1镜像转换为较新的格式2镜像。
下面的示例将一个名为test的RBD映像导出到/tmp/test.dat文件

```bash
[ceph: root@node /]# rbd export rbd/test /tmp/test.dat
```

#### 导入RBD镜像

Red Hat Ceph Storage提供了rbd import命令，用于从文件中导入rbd镜像。
该命令创建一个新映像，并从指定的源路径导入数据。rbd import命令的语法如下:

```bash
rbd import [--export-format {1|2}] [--image-format format-id] [--object-size size-in-B/K/M] [--stripe-unit size-in-B/K/M --stripe-count num] [--image-feature feature-name] ... [--image-shared] src-path [image-spec]
```

--export -format选项指定导入数据的数据格式。
当导入format 2导出的数据时，使用- -stripe-unit， -- stripe-count， --object-size和- -image-feature选项创建新的RBD format 2 image

--export-format参数值必须与相关rbd匹配RBD导入命令

#### 导出和导入RBD镜像的变化

Red Hat Ceph Storage提供rbd export-diff和rbd import-diff命令来导出和导入rbd镜像上两个时间点之间的更改。
语法与rbd export、rbd import命令相同

时间端点可以是:

1. RBD镜像的当前内容，如poolname/imagename

2. RBD镜像的快照，例如poolname/imagename@snapname

开始时间包括:

1. RBD映像的创建日期和时间。例如，不使用- -from-snap选项

2. RBD镜像的快照，例如使用--from-snap snapname选项获取

如果指定了起始点快照，该命令将在创建该快照后导出所做的更改，如果不指定快照，该命令将导出自创建以来的所有更改RBD镜像，与常规的RBD镜像导出操作相同

import-diff操作执行以下有效性检查:

1. 如果export-diff是相对于一个开始快照，那么这个快照也必须存在于目标RBD映像中

2. 如果使用export-diff命令时指定了一个结束快照，则导入数据后在目标RBD镜像中创建相同的快照名称

#### 导出和导入过程的管道

将破折号(-)字符指定为导出操作的目标文件将导致输出转到标准输出(stdout)。

还可以使用破折号字符(-)指定标准输出或标准输入(stdin)作为导出目标或导入源。
可以将两个命令管道到一个命令中

```bash
[ceph: root@node /]# rbd export rbd/img1 - | rbd import - bup/img1
```

rbd merge-diff命令将两个连续增量的rbd export-diff镜像操作的输出合并到一个目标路径上。
该命令一次只能处理两条增量路径

```bash
[ceph: root@node /]# rbd merge-diff first second merged 
```

要在一个命令中合并两个以上的连续增量路径，可以将一个rbd export-diff输出管道到另一个rbd export-diff命令。
使用破折号字符(-)作为管道前的命令中的目标，并作为管道后的命令中的源。

例如，可以将三个增量差异合并到一个命令行上的单个合并目标中。
前一个export-diff命令快照的结束时间必须等于后一个export -diff命令快照的开始时间

```bash
[ceph: root@node /]# rbd merge-diff first second - | rbd merge-diff - third merged
```

rbd merge-diff命令只支持stripe-count为1的rbd镜像



## 7. 扩展块存储操作

### 7.1 配置RBD镜像

#### 7.1.1 RBD镜像

Red Hat Ceph Storage支持两个存储集群之间的RBD镜像。
这允许自动将RBD映像从一个Red Hat Ceph Storage集群复制到另一个远程集群。
这种机制使用异步机制在网络上镜像源(主)RBD映像和目标(次)RBD映像。
如果包含主RBD映像的集群不可用，那么可以从远程集群故障转移到辅助RBD映像，并重新启动使用它的应用程序。

当从源RBD镜像故障转移到镜像RBD镜像时，必须降级源RBD镜像，提升目标RBD镜像。
一个被降级且被锁定不可用，并且提升后的映像在读/写模式下变得可用和可访问。

RBD镜像特性需要RBD-mirror守护进程，rbd-mirror守护进程从远程对等集群提取映像更新，并将它们应用到本地集群映像

#### 7.1.2 支持的镜像配置

RBD镜像支持两种配置:

##### 单向镜像或active-passive

在单向模式下，一个集群的RBD映像以读/写模式可用，远程集群包含镜像。
镜像代理在远程集群上运行。该模式允许配置多个备用集群

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/RBD_mirror_one-way_diagram.svg)

##### 双向镜像或active-active

在双向模式下，Ceph同步源和目标对((primary and secondary)，此模式只允许在两个集群之间进行复制，并且必须在每个集群上配置镜像代理。

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/RBD_mirror_two-way_diagram.svg)

#### 7.1.3 支持Mirroring模式

RBD镜像支持两种模式:pool模式和image模式

##### pool模式

在池模式下，Ceph自动为镜像池中创建的每个RBD映像启用镜像。
当在源集群的池中创建映像时，Ceph会在远程集群上创建辅助映像。

##### image模式

在镜像模式中，可以有选择地为镜像池中的各个RBD映像启用镜像。
在这种模式下，必须显式地选择要在两个集群之间复制的RBD映像。

#### 7.1.4 RBD镜像模式

两个Red Hat Ceph Storage集群间异步镜像的RBD镜像有以下两种模式:

##### 基于日志的镜像

这种模式使用RBD日志映像特性来确保两个Red Hat Ceph Storage集群之间的时间点和崩溃一致性复制。
在修改实际的镜像之前，对RBD镜像的每次写入都首先记录到关联的日志。
远程集群读取此日志，并将更新重播到映像的本地副本

##### 基于快照的镜像

基于快照的镜像通过定时调度或手动创建的RBD镜像镜像快照，在两个Red Hat Ceph Storage集群之间复制崩溃一致性RBD镜像。
远程集群决定两个镜像之间的任何数据或元数据更新快照并将增量复制到映像的本地副本。
RBD fast-diff image特性可以快速确定更新的数据块，而不需要扫描整个RBD图像。
在故障转移场景中使用之前，必须同步两个快照之间的完整增量。
任何部分应用的增量集都将在故障转移时回滚。

#### 7.1.5 管理复制

##### 镜像重新同步

如果两个对等集群之间的状态不一致，rbd-mirror守护进程不会尝试mirror不一致的映像，使用rbd mirror image resync重新同步映像。

```bash
[ceph: root@node /]# rbd mirror image resync mypool/myimage 
```

##### 启用和禁用镜像mirror

使用rbd mirror image enable或rbd mirror image disable在两个对端存储集群上的整个池image模式中启用或禁用mirroring模式。

```bash
[ceph: root@node /]# rbd mirror image enable mypool/myimage
```

##### 使用基于快照的镜像

使用基于快照的镜像，通过禁用镜像和启用快照，将基于日志的镜像转换为基于快照的镜像

```bash
[ceph: root@node /]# rbd mirror image disable mypool/myimage 
Mirroring disabled
```

```bash
[ceph: root@node /]# rbd mirror image enable mypool/myimage snapshot 
Mirroring enabled
```

#### 7.1.6 配置RBD mirror

作为存储管理员，可以通过在红帽Ceph存储集群之间镜像数据映像来提高冗余。
Ceph块设备镜像提供了防止数据丢失的保护，比如站点故障。
为了实现RBD镜像，并使RBD -mirror守护进程发现它的对等体集群，必须有一个注册的对等体和创建的用户帐户。
Red Hat Ceph Storage 5使用rbd mirror pool peer bootstrap create命令自动完成这个过程。

rbd-mirror守护进程的每个实例必须同时连接到本地和远程Ceph集群。
另外，网络在两个数据中心之间必须有足够的带宽来处理镜像工作负载

##### 逐步配置RBD镜像

rbd-mirror守护进程不需要源集群和目标集群具有惟一的内部名称;两者都可以并且应该称自己为ceph。
rbd mirror pool peer boot strap命令利用--site-name选项来描述rbd-mirror守护进程使用的集群。

下面列出了在两个集群之间配置镜像所需的步骤，分别称为prod和backup:

1. 在两个集群prod和backup中创建名称相同的池

2. 创建或修改RBD映像以启用exclusive- lock和journaling

3. 在池上启用池模式mirroring或镜像模式mirroring

4. 在prod集群中，bootstrap存储集群peer并保存bootstrap token

5. 部署rbd-mirror守护进程。
   
   1. 对于单向复制，rbd-mirror守护进程只在备份集群上运行
   
   2. 对于双向复制，rbd-mirror守护进程在两个集群上运行

6. 在备份集群中，导入bootstrap token
   
   1. 对于单向复制，使用--direction rx-only参数

##### 逐步配置单向池模式

在本例中，将看到使用prod和backup集群配置单向镜像所需的详细说明

```bash
[admin@node -]$ ssh admin@prod-node 
[admin@prod-node -]# sudo cephadm shell --mount /home/admin/token/ 
[ceph: root@prod-node /]# ceph osd pool create rbd 32 32 
pool ' rbd' created 
[ceph: root@prod-node /]# ceph osd pool application enable rbd rbd 
enabled application ' rbd' on pool ' rbd' 
[ceph: root@prod-node /]# rbd pool init -p rbd 
[ceph: root@prod-node /]# rbd create my-image --size 1024 --pool rbd --image-feature=exclusive-lock,journaling 
[ceph: root@prod-node /]# rbd mirror pool enable rbd pool 
[ceph: root@prod-node /]# rbd - -image my-image info 
rbd image 'my-image ': 
  size 1 GiB in 256 objects 
  order 22 (4 MiB objects) 
  snapshot_ count: 0 
  id: acf674690a0c 
  block_name_prefix: rbd_ data.acf674690a0c 
  format : 2 
  features: exclusive- lock, journaling 
  op_ features: 
  flags: 
  create_timestamp: Wed Oct 6 22:07:41 2021 
  access_timestamp: Wed Oct 6 22:07:41 2021 
  modify_ timestamp: Wed Oct 6 22:07:41 2021 
  journal: acf674690a0c 
  mirroring state: enabled 
  mirroring mode: journal 
  mirroring global id: d1140b2e-4809-4965-852a-2c21d181819b
  mirroring primary: true 
```

```bash
[ceph: root@prod-node /]# rbd mirror pool peer bootstrap create --site-name prod rbd > /mnt/bootstrap_token_prod 
[ceph: root@prod-node /]# exit 
exit 
[root@prod-node -]# rsync -avP /home/admin/token/bootstrap_token_prod backup-node:/home/admin/token/bootstrap_token_prod 
. . . output omitted ... 
[root@prod-node -]# exit 
logout 
[admin@node -]$ ssh admin@backup-node 
[root@backup-node -]# cephadm shell --mount /home/admin/token/ 
[ceph: root@backup-node /]# ceph osd pool create rbd 32 32
pool ' rbd ' created 
[ceph: root@backup-node /]# ceph osd pool application enable rbd rbd 
enabled application ' rbd' on pool 'rbd' 
[ceph: root@backup-node /]# rbd pool init -p rbd 
[ceph: root@backup-node /]# ceph orch apply rbd-mirror --placement=backup-node.example.com 
Scheduled rbd-mirror update ... 
[ceph: root@backup-node /]# rbd mirror pool peer bootstrap import --site-name backup - -direction rx-only rbd /mnt/bootstrap_token prod
[ceph: root@backup-node /]# rbd -p rbd ls 
my-image
```

backup集群显示以下池信息和状态

```bash
[ceph: root@backup-node /]# rbd mirror pool info rbd 
Mode: pool 
Site Name: backup 
Peer Sites: 
UUID: 5e2f6c8c-a7d 9-4c59-8128-d5c8678f9980 
Name: prod 
Direction: rx-only 
Client: client.rbd-mirror-peer 
[ceph: root@backup-node /]# rbd mirror pool status 
health: OK 
daemon health: OK 
image health: OK 
images: 1 total 
  1 replaying
```

prod cluster显示以下池信息和状态

```bash
[ceph: root@prod-node /]# rbd mirror pool info rbd 
Mode: pool 
Site Name: prod 
Peer Sites: 
UUID: 6c5f860c-b683-44b4-9592-54c8f26ac749 
Name: backup 
Mirror UUID: 7224dlc5-4bd5-4bc3-aa19-e3b34efd8369 
Direction: tx-only 
[ceph: root@prod-node /]# rbd mirror pool status 
health: UNKNOWN 
daemon health: UNKNOWN 
image health: OK 
images: 1 total 
  1 replaying
```

在单向模式下，源集群不知道复制的状态。
目标集群中的RBD镜像代理更新状态信息

##### 故障转移过程

如果主RBD镜像不可用，可以通过以下步骤启用对备RBD镜像的访问:

1. 停止对主RBD映像的访问。这意味着停止使用映像的所有应用程序和虚拟机

2. 使用[rbd mirror image demote pool-name/image-name]()命令降级rbd主镜像

3. 使用[rbd mirror image promote pooI-name/image-name]()命令提升rbd副镜像

4. 恢复对RBD映像的访问。重新启动应用程序和虚拟机

当发生非有序关闭后的故障转移时，必须从备份存储集群中的Ceph Monitor节点提升非主映像。
使用--force选项，因为降级无法传播到主存储集群

### 7.2 提供iSCSI块存储

#### 7.2.1 描述Ceph iSCSI网关

Red Hat Ceph Storage 5可以对存储在集群中的RADOS块设备映像提供高可用的iSCSI访问。
iSCSI协议允许客户端(启动器)通过TCP/IP网络向存储设备(目标器)发送SCSI命令。
每个启动器和目标器都由一个iSCSI限定名称(iSCSI qualified name, IQN)唯一标识。
使用标准iSCSI启动器的客户端可以访问集群存储，而不需要本地Ceph RBD客户端支持。

LinuxI/O目标内核子系统运行在每个iSCSI网关上，以支持iSCSI协议。
SCSI目标子系统以前被称为LIO，现在被称为TCM，或目标核心模块。
TCM子系统利用一个用户空间传递(TCMU)与Ceph librbd库交互，将RBD映像公开给iSCSI客户端

##### 特定于iSCSI的OSD调优

osd (Object Storage Devices)和MONs (monitor)不需要任何与iscsi相关的服务器设置。
主要是为了限制客户端SCSI超时时间，减少集群用于检测故障OSD的延迟超时设置

在cephadm shell中，运行[ceph tell <daemon_type>.<id> config set]()命令设置超时参数

```bash
[root@node -]# ceph config set osd osd_heartbeat_interval 5 
[root@node -]# ceph config set osd osd_heartbeat_grace 20 
[root@node -]# ceph config set osd osd_client_watch_timeout 15 
```

#### 7.2.2 部署iSCSI网关

可以将iSCSI网关部署在专用节点上，也可以与osd节点同时部署。
部署Red Hat Ceph Storage iSCSI网关前，需要满足以下前提条件:

1. 请安装Red Hat Enterprise Linux 8.3及以上版本的iSCSI网关节点

2. 有一个运行的集群，运行Red Hat Ceph Storage 5或更高版本

3. 为iSCSI网关节点上作为目标公开的每个RBD映像提供90个RAM MiB

4. 在每个Ceph iSCSI节点的防火墙上开放TCP端口3260和5000

5. 创建一个新的RADOS块设备或使用一个现有的可用设备

##### 创建配置文件

部署iSCSI网关节点时，使用cephadm shell创建一个/etc/ceph/目录下名为iscsi-gateway.yaml的配置文件。
文件应该显示如下:

```yaml
service_type: iscsi
service_id: iscsi
placement:
  hosts:
    - serverc.lab.example.com
    - servere.lab.example.com
spec: 
  pool: POOL_NAME
  trusted_ip_list: "172.25.250.12,172.25.250.14"
  api_port: 5000
  api_secure: false
  api_user: admin
  api_password: redhat
```

##### 应用规格文件和部署iSCSI网关

使用ceph orch apply命令通过使用-i选项来使用规范文件来实现该配置

```bash
[ceph: root@node /]# ceph orch apply -i /etc/ceph/iscsi-gateway.yaml 
Scheduled iscsi.iscsi update ... 
```

列出网关并验证它们是否存在

```bash
[ceph: root@node /]# ceph dashboard iscsi-gateway-list
{"gateways": {"serverc.lab.example.com": {"service url": "http:// 
admin:redhat@172.25.250.12:5000"}, "servere.lab.example.com": {"service_ url": 
"http://admin: redhat@172.25.250.14:5000"}}} 
```

打开一个web浏览器，并以具有管理权限的用户身份登录到Ceph Dashboard。
在“Ceph Dashboard”界面，单击“Block-->iSCSI”，进入“iSCSI Overview”界面。

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/block/gui-dashboard-iscsi-overview.png)

配置Ceph Dashboard访问iSCSI网关api后，使用Ceph Dashboard管理iSCSI目标。
使用Ceph仪表板来创建、查看、编辑和删除iSCSI目标

#### 7.2.3 配置iSCSI Target

使用Ceph Dashboard或ceph-iscsi [gwcli]()实用程序配置iSCSI目标

这些是从Ceph仪表板配置iSCSI目标的示例步骤。

1. 登录Dashboard。

2. 在导航菜单中单击“Block➔iSCSI”

3. 单击“Targets”页签

4. 在“创建”列表中选择“创建”

5. 在“创建目标”窗口中，设置以下参数:
   
   1. 修改Target IQN(可选)
   
   2. 单击“+添加portal”，选择至少两个网关中的第一个
   
   3. 单击“+添加image”，选择需要导出的image
   
   4. 单击“创建目标”

#### 7.2.4 配置iSCSI启动器

配置iSCSI启动器与Ceph iSCSI网关通信与任何行业标准iSCSI网关相同。
对于RHEL 8，需要安装iscsi-initiator-utils和device-mapper-multipath软件包。
iscsi-initiator-utils包中包含配置iSCSI启动器所需的实用程序。
当使用多个iSCSI网关时，可以通过集群的iSCSI目标配置支持多路径的客户端在网关之间进行故障转移。

系统可以通过多个不同的通信路径访问相同的存储设备，无论这些路径使用的是Fibre Channel、SAS、iSCSI还是其他技术。
多路径允许配置一个虚拟设备，使其可以使用任何这些通信路径来访问存储。
如果其中一条路径出现故障，系统会自动切换到其他路径。
如果部署单个iSCSI网关进行测试，则无需配置多路径。

在本示例中，配置iSCSI启动器使用多路径支持和登录iSCSI目标器。
配置客户端的CHAP用户名和密码登录iSCSI目标器。

1. 安装iSCSI启动器工具
   **[root@foundation0]#**

   ```bash
   yum -y install iscsi-initiator-utils
   ```

2. 配置多路径I/O
   
   1. 安装多路径工具
      
      ```bash
      yum install device-mapper-multipath
      ```
   
   2. 启用并创建默认多路径配置
      
      ```bash
      mpathconf --enable --with_multipathd y 
      ```
   
   3. 在/etc/multipath.conf添加如下内容
      
      ```bash
      cat >> /etc/multipath.conf <<EOF
      
      devices { 
          device { 
              vendor                 "LIO-ORG" 
              hardware_handler       "1 alua" 
              path_grouping_policy   "failover" 
              path_selector          "queue-length 0"
              failback               60
              path_checker           tur
              prio                   alua
              prio_args              exclusive_pref_bit
              fast_io_fail_tmo       25
              no_path_retry          queue
          } 
      }
      EOF
      ```
      
   4. 重新启动multipathd服务
      
      ```bash
      systemctl reload multipathd
      ```
   
3. 如果需要进行配置，设置CHAP认证

在/etc/iscsi/iscsid.conf中更新CHAP用户名和密码

```bash
:<<EOF
node.session.auth.authmethod = CHAP 
node.session.auth.username = iscsiuser1
node.session.auth.password = temp12345678
EOF

sed -i \
-e '/^#node.*authmethod/s/#//' \
-e '/^#node.*username /{s/#//;s/=.*/= iscsiuser1/}' \
-e '/^#node.*password /{s/#//;s/=.*/= temp12345678/}' \
/etc/iscsi/iscsid.conf

systemctl restart iscsi
systemctl enable iscsid

```

4. 发现目标并登录iSCSI portal，查看目标及其多路径配置
   
   1. 发现iSCSI portal
      
      ```bash
      PORTAL=serverc
      iscsiadm \
      	--mode discoverydb --type sendtargets \
      	--portal $PORTAL --discover
      ```
      
   2. 登录iSCSI portal
      
      ```bash
      PORTAL=$(iscsiadm --mode discoverydb --type sendtargets --portal $PORTAL --discover | cut -d, -f1)
      TARGETNAME=$(iscsiadm --mode discoverydb --type sendtargets --portal $PORTAL --discover | awk '{print $2}' | uniq)
      
      for i in $PORTAL; do
        for j in logout login; do
      	iscsiadm --mode node \
      	--targetname $TARGETNAME \
      	--portal $i --$j
      	done
      done
      
      iscsiadm -m session -P 3
      ```
      
   3. 验证任何附加的SCSI目标
      
      ```bash
      lsblk
      ```
      
   4. 使用multipath命令显示在故障转移配置中设置的设备，每个路径都有一个优先级组
      
      ```bash
      multipath -ll
      ```


## 8. 使用 RADOS 网关提供对象存储

### 8.1 部署对象存储网关

#### 8.1.1 介绍对象存储

1. 对象存储将数据存储为离散项，每个单独称为对象。
   与文件系统中的文件不同，对象不是按目录和子目录树组织的。
   相反，对象存储在平面名称空间中。
   通过使用对象的唯一对象ID(也称为对象键)检索每个对象

2. 应用程序不使用普通的文件系统操作来访问对象数据。
   相反，应用程序访问一个REST API来发送和接收对象。
   redhat Ceph Storage支持两种最常用的对象资源: Amazon S3(简单存储服务)和 OpenStack Swift (OpenStack对象存储)

3. Amazon S3将对象存储的平面命名空间称为桶，OpenStack Swift将其称为容器。
   因为名称空间是平面的，所以桶和容器都不能嵌套。
   Ceph通常使用桶这个术语

4. 一个用户帐户可以访问同一个存储集群中的多个桶。
   每个桶可以有不同的访问权限，用于存储不同用例的对象

5. 对象存储的优点是易于使用、扩展和扩展。
   因为每个对象都有一个惟一的ID，所以可以在用户不知道对象位置的情况下存储或检索它

6. 没有目录层次结构，简化了对象之间的关系

7. 与文件类似，对象包含二进制数据流，并且可以增长到任意大的大小

8. 对象还包含关于对象数据的元数据，并支持扩展元数据信息，通常以键-值对的形式存在。
   您还可以创建自己的元数据键，并将自定义信息作为键值存储在对象中

#### 8.1.2 介绍RADOS网关

1. RADOS网关，也被称为RGW (Object Gateway)，是一种服务，为使用标准对象存储ap的客户端提供对Ceph集群的访问。
   RADOS网关同时支持Amazon S3和OpenStack Swift的api

2. 核心守护进程radosgw构建在librados库之上。
   这个守护进程提供一个基于Beast HTTP、WebSocket和网络协议库的web服务接口，作为处理API请求的前端

3. radosgw是Red Hat Ceph Storage的客户端，提供对其他客户端应用程序的对象访问。
   客户端应用程序使用标准的apl与RADOS网关通信，而RADOS网关使用librados模块调用与Ceph集群通信

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/ObjectGateway_Architecture.svg)

RADOS网关提供了[radosgw-admin]()实用程序，用于创建使用该网关的用户。
这些用户只能访问网关，而不是直接访问存储集群的cdephx用户。
在提交Amazon S3或OpenStack Swift API请求时，RADOS网关客户端使用这些网关用户帐户进行鉴权。
通过RADOS网关对网关用户进行身份验证后，网关使用cephx凭据向存储集群进行身份验证，以处理对象请求。
网关用户也可以通过集成基于ldap的外部认证服务进行管理

RADOS网关服务自动在每个区域的基础上创建池。
这些池使用配置数据库中的放置组值，并使用默认的CRUSH层次结构

默认池设置对于生产环境可能不是最优的

RADOS网关为默认区域创建多个池:

1. rgw. root 存储记录信息

2. default.rgw.control 用作控制池

3. default.rgw.meta 存储user_key和其他关键元数据

4. default.rgw.log 包含所有bucket或container以及对象操作的日志，如create，read，delete

5. default.rgw.buckets.index 存储桶的索引

6. default.rgw.buckets.data 存储桶数据

7. default.rgw.buckets.non-ec用于multipart对象元数据上传

可以使用自定义设置手动创建池。
Red Hat建议将区域名称作为手动创建的池的前缀，`.<zone-name>.rgw.control`
例如：.us-east1-1.rgw.buckets.data 作为us-east-1区域的池名称

##### RADOS网关支持静态Web内容托管

RADOS网关支持静态网站托管在S3桶中，这可以比使用虚拟机更有效的网站托管。
这适用于只使用静态元素的网站，如XHTML或HTML文件，或CSS

为静态web主机部署RADOS网关实例有限制

实例也不能用于S3或Swift API访问

实例的域名应该与标准S3和Swift AP的域名不同，而且不能重叠。网关实例

实例应该使用不同于标准S3和Swift API网关实例的面向公共的IP地址

#### 8.1.3 RADOS网关部署

cephadm工具将RADOS网关服务部署为一组守护进程，用于管理单个集群或多站点部署。
使用`client.rgw.*`来定义新的RADOS网关守护进程的参数和特征

使用Ceph Orchestrator部署或删除RADOS网关服务。
通过命令行接口或服务规范文件使用Ceph Orchestrator

```bash
[ceph: root@node /)# ceph orch apply rgw <service-name> \
	[--realm=<realm>] \ 
	[--zone=<zone>] \
	--port=<port> \
	--placement="<num-daemons> <hostl> ... " \ 
	[--unmanaged]
```

在本例中，Ceph Orchestrator在单个集群中使用两个守护进程部署my_rgw_service RADOS网关服务，并在80端口上提供服务

```bash
[ceph: root@node /]# ceph orch apply rgw my_rgw_service
```

如果`client.rgw.*`未定义或在构建时传递给Ceph协调器，然后部署使用这些默认设置。

下面的示例YAML文件包含为RADOS Gateway部署定义的公共参数

```yaml
service_type: rgw 
service_name : rgw_service_name 
placement: 
  count: 2 
  hosts: 
    - node01 
    - node02 
spec: 
  rgw_frontend_port: 8080 
  rgw_realm: realm_name 
  rgw_zone: zone_name 
  ssl: true 
  rgw_frontend_ssl_certificate: |
    -----BEGIN PRIVATE KEY-----
    ... output omitted ... 
    -----END PRIVATE KEY-----
    -----BEGIN CERTIFICATE-----
    ... output omitted ... 
    -----END CERTIFICATE-----
networks: 
  - 172.25.200.0/24 
```

在本例中，创建RGW服务的参数与前一个服务类似，但现在使用的是CLI

```bash
[ceph: root@node /]# ceph orch apply rgw rgw_service_name --realm=realm_name \ 
--zone=zone_name --port 8080 --placement="2 node01 node02" --ssl 
```

注意，在服务规范文件中，realm、zone和port的参数名称与CLI使用的参数名称不同。
RGW实例使用的网络、ssl证书内容等参数只能通过服务规范文件定义。

count参数设置在hosts参数中定义的每台服务器上创建RGW实例的数量。
如果创建多个实例，那么Ceph协调器将第一个实例的端口设置为指定的rgw_frontend_port或port值。
对于后续的每个实例，端口值增加1。使用前面的YAML文件示例，服务部署创建:

1. node0l服务器中的两个RGW实例，一个端口为8080，另一个端口为8081

2. node02服务器中的两个RGW实例，一个端口为8080，另一个端口为8081

每个实例都有自己唯一的端口供访问，并对请求创建相同的响应。
通过部署提供单一业务IP地址和端口的负载均衡器服务来配置RADOS网关的高可用性

Ceph编排器服务通过使用该格式来命名守护进程`rgw.<realm>.<zone>.<host>.<random-string>`

##### 自定义服务配置

使用集群配置文件client.rgw section中rgw_frontend参数中的port选项为RADOS网关配置Beast前端web端口。
使用ceph config命令查看当前配置

```bash
[ceph: root@node /]# ceph config get client.rgw rgw_frontends 
beast port=7480
```

使用TLS/SSL (Transport Layer Security/Secure Socket Layer)协议时，在端口号的末尾使用s字符定义端口，例如port=443。
端口选项支持使用加号字符(+)的双端口配置，以便用户可以访问在两个不同的端口上的RADOS网关。

例如，rgw_frontend配置可以使RADOS网关在80/TCP端口上监听，并在443/TCP端口上支持TLS/SSL

```bash
[ceph: root@node /]# ceph config get client.rgw rgw_frontends 
beast port=80+443s
```

#### 8.1.4 使用Beast前端

RADOS网关提供Beast嵌入式HTTP服务器作为前端。
Beast前端使用Boost.Beast 库来做HTTP解析以及使用Boost.Asio库来做异步网络I/O

##### Beast的配置选项

通过配置来自证书颁发机构(CA)的证书，以及RGW实例的主机名和匹配的密钥，配置Beast web服务器使用TLS

Beast配置选项通过Ceph配置文件或配置数据库传递给嵌入式web服务器。
如果未指定值，则默认值为空

**port and ssl_port**

设置IPv4和IPv6协议的侦听端口号，可以多次指定，如port=80 port=8000

**endpoint and ssl_endpoint**

以address [:port]的形式设置侦听地址，可以多次指定，如endpoint= [:: 1] endpoint=192.168. 0.100: 8000

**ssl_certificate**

指定用于启用SSL的端点的SSL证书文件的路径

**ssl_private_key**

指定SSL私钥，但是如果没有提供值，则使用ssl_certificate指定的文件作为私钥

**tcp_nodelay**

在某些环境下设置性能优化参数

Red Hat建议使用HAProxy和keepalive服务在生产环境中配置TLS/ SSL访问

#### 8.1.5 高可用Proxy和加密

当RADOS Gateway业务负载增加时，可以部署更多的RGW实例，以支持业务负载。
可以在单个zone组部署中添加实例，但是要考虑到每个RGW实例都有自己的IP地址，并且很难在单个zone中平衡对不同实例的请求

相反，配置HAProxy和keepalive来平衡RADOS网关服务器之间的负载。
HAProxy只提供一个IP地址，它平衡所有RGW实例的请求

Keepalived确保代理节点保持相同的呈现IP地址，与节点可用性无关

为HAProxy和keepa live服务配置至少两个独立的主机，以保持高可用性

HAProxy服务可以配置为使用HTTPS协议。要启用HTTPS，需要为配置生成SSL密钥和证书。
如果没有来自证书颁发机构的证书，那么请使用自签名证书

##### 服务器端加密

可以启用服务器端加密，以便在无法通过SSL发送加密请求时，允许使用不安全的HTTP向RADOS网关服务发送请求。
目前仅在使用Amazon S3 API时支持服务器端加密场景。

有两个选项配置服务器端加密的RADOS网关，客户提供的密钥或密钥管理服务

##### 客户提供的密钥

该选项根据Amazon SSE-C规范实现。
对RADOS网关服务的每个读或写请求都包含一个用户通过S3客户端提供的加密密钥

一个对象只能用一个密钥加密，用户使用不同的密钥加密不同的对象。
跟踪用于加密每个对象的密钥是用户的责任

##### 密钥管理服务

通过配置密钥管理服务，可以安全地保存RADOS Gateway服务的密钥。
当配置密钥管理服务时，RADOS网关服务按需检索密钥，以对对象进行加密或解密。

下图演示了RADOS网关和示例HashiCorp Vault密钥管理服务之间的加密流程

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/Ceph_HashiCorpVault_Integration.svg)

目前，已测试的RADOS网关密钥管理服务实现包括HashiCorp Vault和OpenStack Barbican

### 8.2 配置多站点对象存储部署

#### 8.2.1 RADOS网关多站点部署

Ceph RADOS网关支持在一个全局命名空间内的多站点部署，这允许RADOS网关在多个Red Hat Ceph存储集群之间自动复制对象数据。
一个常见的支持用例是活动/活动复制用于灾难恢复的地理上独立的集群

最新的多站点配置简化了故障转移和故障恢复过程，支持集群之间的主动/主动复制配置，并合并了一些新特性，比如更简单的配置和对名称空间的支持

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/RADOSGW-MultiSite-Diagram.svg)

##### 多站点组件

下面列出了多站点组件和定义

**zone**

zone由自己的Red Hat Ceph存储集群支持。每个区域都有一个或多个与之相关联的RADOS网关

**zone group**

zone group是一个或多个zone的集合。存储在zone组中的一个zone中的数据会复制到该zone组中的所有其他zone。
每个区域组中的一个区域被指定为该组的主区域。zone组中的其他zone均为二级zone

**realm**

realm表示多站点复制空间中所有对象和存储桶的全局命名空间。
一个realm包含一个或多个专区组，每个专区组包含一个或多个专区。
域中的一个zone组被指定为主zone组，其他的zone组被指定为从zone组。
环境中的所有RADOS网关都从主区域组和主区域的RADOS网关中提取配置

因为主区域组中的主区域处理所有元数据更新，所以创建用户等操作必须在主区域中进行

可以在辅助区域执行元数据操作，但不建议这样做，因为元数据不会在该realm上同步。
这种行为可能导致元数据碎片和区域之间的配置不一致

这个架构可以用几种方式构建:

1. 单个zone配置在域中有一个zone组和一个zone。
   一个或多个(可能是负载均衡的)RADOS网关由一个红帽Ceph存储集群支持

2. multizone配置包含一个zone组和多个zone。
   每个zone由一个或多个RADOS网关和一个独立的Red Hat Ceph Storage集群支持。
   存储在一个zone内的数据会复制到zone组内的所有zone。
   如果一个区域发生灾难性故障，这可以用于灾难恢复

3. multizone组配置包含多个zone组，每个zone组包含一个或多个zone。
   通过多区域组可以管理一个区域内或多个区域内的RADOS网关的地理位置

4. 多区域配置允许使用相同的硬件来支持多个对象名称空间，这些名称空间在区域组和区域之间是通用的

一个最小的RADOS Gateway多站点部署需要两个红帽Ceph存储集群，每个集群需要一个RADOS Gateway。
它们存在于同一个realm中，并被分配到相同的主区域组。
一个RADOS网关与该区域组中的主区域相关联。另一个与该区域组中的一个独立辅助区域相关联。
这是一个基本的多区域配置

##### 更改Periods和Epochs

每个realm都有一个相关联的Period，每个Period都有一个相关联的epoch。
Period用于跟踪realm、区域组和区域在特定时间的配置状态。
epoch是用于跟踪特定realm期间配置更改的版本号。
每个时期都有一个唯一的ID，包含realm配置，并且知道以前的Period ID

更新主域配置时，RADOS Gateway服务会更新Period。
这个新Period就成了realm的当前Period，而这个Period的epoch又依次增加。
对于其他配置更改，只增加epoch，Period不变

##### 多站点同步流程

RADOS网关同步所有主、从zone group集之间的元数据和数据操作。
元数据操作与桶相关:桶的创建、桶的删除、桶的启停、桶的用户管理。
元数据主分区位于主分区组的主分区中，负责管理元数据的更新。
数据操作是那些与对象相关的操作

当多站点配置激活时，RADOS网关会在主备区域之间进行初始的全同步。
后续更新是增量式的

当RADOS Gateway将数据写入一个区域组内的任何区域时，它会在其他区域组中的所有区域之间同步该数据。
当RADOS网关同步数据时，所有活动网关都会更新数据日志，并通知其他网关。
当RADOS网关因为桶或用户操作而同步元数据时，master会更新元数据日志，并通知其他RADOS网关

#### 8.2.2 配置多站点RGW部署

通过使用Ceph orchestrator命令行接口或使用服务规范文件，可以部署、配置和删除多站点Ceph RADOS网关实例

##### 多站点配置示例

下面的示例配置一个realm，其中一个区域组包含两个区域，一个作为主区域，另一个作为辅助区域。
每个区域有一个与之相关联的RADOS Gateway实例

##### 配置主区域

这些示例步骤在主区域中配置RADOS Gateway实例

1. 创建realm
   
   ```bash
   [ceph: root@node01 /]# radosgw-admin realm create --default --rgw-realm=gold
   ```

2. 创建主zone组
   
   ```bash
   [ceph: root@node01 /]# radosgw-admin zonegroup create --rgw-zonegroup=us --master --default --endpoints=http://node01:80
   ```

3. 创建主zone
   
   ```bash
   [ceph: root@node01 /]# radosgw-admin zone create --rgw-zone=datacenter01 --master --rgw-zonegroup=us --endpoints=http://node01:80 --access-key=12345 --secret=67890 --default
   ```

4. 创建系统用户
   
   ```bash
   [ceph: root@node01 /]# radosgw-admin user create --uid=sysadm --display-name="SysAdmin" --access-key=12345 --secret=67890 --system 
   ```

5. 提交更改
   
   ```bash
   [ceph: root@node01 /]# radosgw-admin period update --commit 
   ```

6. 创建主zone的RADOS Gateway服务
   
   ```bash
   (ceph: root@node /)# ceph orch apply rgw gold-service --realm=gold --zone=datacenter81 --placement="1 node81"
   ```

7. 更新配置数据库中的区域名称
   
   ```bash
   (ceph: root@node01 /)# ceph config set client.rgw rgw_zone datacenter01
   ```

##### 配置辅助zone

这些示例步骤在辅助区域上配置RADOS Gateway实例

1. 拉取realm配置
   
   ```bash
   [ceph: root@node02 /]# radosgw-admin realm pull --rgw-realm=gold --url=http://node01:80 --access-key=12345 --secret=67898 --default 
   ```

2. 拉取 period
   
   ```bash
   (ceph: root@node02 /]# radosgw-admin period pull --url=http://node81:8888 --access-key=12345 --secret=67898
   ```

3. 创建辅助zone
   
   ```bash
   [ceph: root@node /]# radosgw-admin zone create --rgw-zone=datacenter02 --rgw-zonegroup=us --endpoints=http://node02:80 --access-key=12345 --secret=67898 --default
   ```
   
   将zone加入到zone组时，可以使用--read-only选项将其设置为只读

4. 提交更改
   
   ```bash
   [ceph: root@node02 ]# radosgw-admin period update --commit 
   ```

5. 创建辅助区域的RADOS Gateway服务
   
   ```bash
   [ceph: root@node02 /]# ceph orch apply rgw gold-service --realm=gold --zone=datacenter02 --placement="1 node02" 
   ```

6. 更新配置数据库中的区域名称
   
   ```bash
   [ceph: root@node02 /]# ceph config set client.rgw rgw_zone datacenter02
   ```
   
   使用radosgw-admin sync status命令查看同步状态

#### 8.2.3 管理区域故障转移

在多站点部署中，当主区域不可用时，备用区域可以继续为读写请求提供服务。
但由于主分区不可用，无法创建新的桶和用户。
如果主区域不能立即恢复，则提升一个辅助区域作为主区域的替代品。

如果要提升辅助zone，需要修改zone和zone组，并提交period更新

1. 将主区域指向辅助区域(datacenter02)
   
   ```bash
   [ceph: root@node02 /]# radosgw-admin zone modify --master --rgw-zone=datacenter02 
   ```

2. 修改主分区角色后，需要更新主分区组
   
   ```bash
   [ceph: root@node02 /]# radosgw-admin zonegroup modify --rgw-zonegroup=us --endpoints=http://node02:80
   ```

3. 提交更改
   
   ```bash
   [ceph: root@node02 /]# radosgw-admin period update --commit
   ```

#### 8.2.4 元数据搜索功能

大型对象正变得越来越普遍。
用户仍然需要对对象进行智能访问，以便从对象元数据中提取额外的信息。
与对象关联的元数据提供关于对象的深刻信息。
RADOS Gateway支持通过Elasticsearch查询对象存储中的元数据，并根据用户自定义的元数据对对象进行索引

RADOS网关支持Elasticsearch作为multimode架构的一个组件

Elasticsearch可以管理zone组中所有对象的元数据。
一个区域组可以包含存储对象的区域，而其他区域则存储这些对象的元数据

以下命令将metadata-zone zone定义为由Elasticsearch管理的元数据区域:

```bash
[ceph: root@node /]# radosgw-admin zone modify --rgw-zone=metadata-zone --tier-type=elasticsearch --tier-config=endpoint=http://node03:9200, num_shards=10,num_replicas=1 
```

--tier-type 选项将区域类型设置为lastsearch

--tier-config选项定义Elasticsearch区域的配置

endpoint参数定义了访问Elasticsearch服务器的端点

num_shards参数定义了E asticsearch使用的分片数量

num_replicas参数指定Elasticsearch使用的副本数量

#### 8.2.5 RADOS网关多站点监控

可以在Ceph存储仪表板中监控RADOS网关的性能和使用统计数据。
为了将RADOS网关与Ceph存储仪表板集成，必须在JSON格式文件中添加带有系统标志的RGW用户登录凭证

当向仪表板添加rgw系统用户时，使用ceph dashboard set-rgw-api-access-key和ceph dashboard set-rgwapi-secret- key命令提供访问密钥和密钥

```bash
[ceph: root@node /]# cat access_key 
{'myzone. node.tdncax ': ' ACCESS_KEY '} 
[ceph: root@node /]# cat secret_key 
{'myzone. node .tdncax ': ' SECRET_KEY '} 
[ceph: root@node /]# ceph dashboard set-rgw-api-access-key -i access_key 
Option RGW__API_ACCESS_KEY updated 
[ceph: root@node /]# ceph dashboard set-rgw-api-secret-key -i secret_key 
Option RGW__API_SECRET_KEY updated 
```

Ceph RADOS Gateway服务详情可通过登录“Dashboard”，单击“Object Gateway”查看。可以选择守护进程、用户或桶。
在Daemons子菜单中，仪表板显示了RGW守护进程的列表

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/ObjectGateway_DaemonList.png)

单击守护进程名称，可以查看详细信息和性能统计信息

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/ObjectGateway_Dashboard_PerformanceCounter.png)

如果需要查看业务的整体性能，单击“整体性能”

![a](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/object/ObjectGateway_Dashboard_ServicePerformance.png)
## 9. 使用 REST API 访问对象存储

### 9.1 使用Amazon S3 API提供对象存储

#### 9.1.1 RADOS网关中的Amazon S3 API

通过Amazon S3接口，开发人员可以通过兼容Amazon S3接口管理对象存储资源。
通过S3接口实现的应用可以与除RADOS网关之外的其他兼容S3的对象存储服务互操作，并将存储从其他位置迁移到Ceph存储集群。
在混合云环境中，可以配置应用程序以使用不同的身份验证密钥、区域和供应商服务，使用相同的API无缝地混合私有企业和公共云资源和存储位置。

Amazon S3接口定义了将对象存储为桶的名称空间。
应用通过S3接口访问和管理对象和桶时，需要使用RADOS Gateway用户进行认证。
每个用户都有一个识别用户的访问密钥和一个验证用户身份的密钥

在使用Amazon S3 API时，需要考虑对象和元数据的大小限制:

1. 对象大小的最小值为0B，最大值为5tb

2. 单个上传操作的最大容量为5GB

3. 使用multipart上传功能上传大于100MB的对象。

4. 单个HTTP请求的元数据最大长度为16000字节

#### 9.1.2 创建Amazon S3 API的用户

首先创建所需的RADOS网关用户，然后使用它们用网关对Amazon S3客户端进行身份验证。
使用radosgw-adrnin user create命令创建RADOS网关用户

在创建RADOS Gateway用户时，需要同时使用--uid和--display-name选项，并指定唯一的帐户名和用户友好的显示名。
使用--access-key和--secret选项为RADOS用户指定自定义AWS帐户和密钥

```bash
[ceph: root@node /]# radosgw-admin user create \
	--uid=testuser \
	--display-name="Test User" \
	--email=test@example.com \ 
	--access-key=12345 \
	--secret=67898 
. . . output omitted ... 
"keys": 
{ 
"user": "testuser", 
"access_key": "12345",
"secret_key": "67890" 
}
```

如果不指定access key和secret key，则radosgw-admin命令会自动生成并显示在输出信息中

```bash
[ceph: root@node /]# radosgw-admin user create \
	--uid=s3user \ 
	--display-name="Amazon S3 API user" 
. . . output omitted ... 
"keys": [ 
{ 
"user" : "s3user", 
"access_key": "8PI209ARWNGJI99K8TOS", 
"secret_key": "brKaQdhyR022znWVVdDLuAEafRjbrAorr0GoXNl" 
}
```

当radosgw-admin命令自动生成访问密钥和密钥时，任一密钥都可能包含一个JSON转义字符(\)。
客户端可能无法正确处理此字符。可以重新生成或手动指定键来避免此问题

#### 9.1.3 管理Ceph对象网关用户

要重新生成一个现有用户的密钥，使用带有-gen-secret选项的radosgw-admin key create命令

```bash
[ceph: root@node /]# radosgw-admin key create \
	--uid=s3user \ 
	--access-key="8PI2D9ARWNGJI99K8TOS" \
	--gen-secret 
... output omitted ... 
"keys": 
{ 
"user" : "s3user", 
"access_key": "8PI209ARWNGJI99K8TOS", 
"secret_key": "MFVxrGNMBjK007JscLFbEyrEmJFnLl43PHSswpLC" 
} 
```

若要为现有用户添加访问键，请使用--gen-access-key选项。
创建额外的键可以方便地向需要不同或唯一键的多个应用程序授予相同的用户访问权

```bash
[ceph: root@node /]# radosgw-admin key create \
	--uid=s3user \
	--gen-access-key 
```

要从用户那里移除访问密钥和相关的密钥，可以使用带有--access- key选项的radosgw-admin key rm命令。
这对于删除单个应用程序访问而不影响对其他键的访问非常有用

```bash
[ceph: root@node /]# radosgw-admin key rm \
	--uid=s3user \
	--access-key=8PI209ARWNGJI99K8TOS 
```

请使用radosgw-admin user suspend和radosgw-admin user enable命令暂时关闭和启用RADOS Gateway用户。
当挂起时，用户的子用户也会挂起，并且无法与RADOS网关服务交互。

可以修改用户的邮箱、显示名、按键和访问控制级别等信息。
访问控制级别包括:读、写、读写和完全。完全访问级别包括读写级别和访问控制管理能力

```bash
[ceph: root@node /)# radosgw-admin user modify \
	--uid=johndoe \
	--access=full
```

要删除用户并删除他们的对象和存储桶，请使用--purge-data选项

```bash
[ceph: root@node /]# radosgw-admin user rm \
	--uid=s3user \
	--purge-data
```

通过设置配额来限制用户或桶使用的存储空间。请先设置配额参数，再启用配额。
如果需要禁用配额，请将quota参数设置为负值

桶配额适用于指定UUID所拥有的所有桶，与访问或向这些桶进行上传的用户无关

本例中为“app1”用户设置的最大配额为1024个对象。启用用户配额

```bash
[ceph: root@node /]# radosgw-admin quota set \
	--quota-scope=user \
	--uid=app1 \
	--max-objects=1024 
[ceph: root@node /]# radosgw-admin quota enable \
	--quota-scope=user \
	--uid=app1 
```

同样，通过将- -quota-scope选项设置为桶，可以对桶使用配额。
本例中设置的日志历史桶大小不超过1024字节

```bash
[ceph: root@node /]# radosgw-admin quota set \
	--quota-scope=bucket \
	--uid=loghistory \
	--max-objects=1024
[ceph: root@node /)# radosgw-admin quota enable \
	--quota-scope=bucket \
	--uid=loghistory
```

全局配额影响集群中的所有桶

```bash
[ceph: root@node /)# radosgw-admin global quota set \
	--quota-scope bucket \
	--max-objects 2048 
[ceph: root@node /)# radosgw-admin global quota enable \
	--quota-scope bucket
```

如果需要在zone和period配置中实现，可以使用radosgw-admin period update - -commit命令提交修改。
或者，重新启动RGW实例来实现配额

可以使用以下命令检索用户信息和统计信息

|       动作       | 命令                                     |
| :--------------: | ---------------------------------------- |
|   获取用户信息   | [radosgw-admin user info - -uid=uid]()   |
| 检索用户统计信息 | [radosgw-admin user stats - - uid=uid]() |

存储管理员通过监控带宽使用情况来确定存储资源的使用情况或用户带宽使用情况。
监视还可以帮助查找不活动的应用程序或不适当的用户配额。

使用radosgw-admin user stats和radosgw-admin user info命令查看用户信息和统计信息

```bash
[ceph: root@node /]# radosgw-admin user info --uid=uid 
[ceph: root@node /]# radosgw-admin user stats --uid=uid 
```

使用radosgw-admin usage show命令显示某用户在指定日期的使用统计信息

```bash
[ceph: root@node /)# radosgw-admin usage show \
	--uid=uid \
	--start-date=start \
	--end-date=end
```

使用radosgw-admin usage show命令查看所有用户的统计信息。
使用这些总体统计信息可以帮助理解对象存储模式，并为扩展RADOS网关服务规划新实例的部署

```bash
[ceph: root@node /]# radosgw-admin usage show \
	--show-log-entries=false
```

#### 9.1.4 使用RADOS网关访问S3对象

Amazon S3 API支持多种桶URL格式，包括http://server.example.com/bucket或http://bucket.server.example.com/客户端，
有些客户端，例如s3cmd命令，只支持第二种URL格式。
默认情况下，RADOS网关不启用该格式。要启用第二种URL格式，需要设置rgw_dns名称

参数设置DNS后缀

```bash
[ceph: root@node /]# ceph config set client.rgw rgw_dns_name dns_suffix
```

其中dns_suffix是用于创建bucket名称的完全限定域名

除了配置rgw_dns_name之外，还必须为该域配置一个指向RADOS网关IP地址的通配符DNS记录。
不同的DNS服务器，实现通配符DNS表项的语法也不同

##### 使用Amazon S3 API客户端

来自awscli安装包的命令通过使用S3 API支持桶和对象管理。
可以使用aws mb命令创建桶。
这个示例命令创建名为demobucket的桶

```bash
[ceph: root@node /]# aws s3 mb s3://demobucket
```

使用aws cp命令上传对象到桶中。
这个示例命令使用本地文件/tmp/demoobject上传一个名为demoobject的对象到demobucket桶

```bash
[ceph: root@node /]# aws \
	--acl=public-read-write \
	s3 cp /tmp/demoobject s3://demobucket/demoobject 
```

radosgw-admin命令支持对桶的操作，如radosgw-admin桶列表和radosgw-admin桶rm命令

S3有多种公共客户端，如awscli、cloudberry、cyberduck和curl，这些客户端提供了对对象存储的访问，支持S3 API 

##### S3桶版本、生命周期和策略

S3桶版本支持在一个桶中存储一个对象的多个版本。
RADOS Gateway支持版本桶，为上传到桶中的对象添加版本标识符。
桶的所有者将桶配置为版本桶

通过使用为一组桶对象定义的规则，RADOS Gateway还支持S3 API对象过期。
每个规则都有一个前缀，用于选择对象，以及对象不可用的天数

RADOS网关只支持应用于桶的Amazon S3 API策略语言的子集。
用户、组或角色不支持策略。桶策略通过标准的S3操作进行管理，而不是使用radosgw-admin命令

S3策略使用JSON格式定义以下元素:

1. Resource键定义了策略修改的权限。该策略使用与资源关联的Amazon Resource Name (ARN)来识别它

2. Actions键定义资源允许或拒绝的操作。每个资源都有一组可用的操作

3. Effect键指示策略是否允许或拒绝先前为资源定义的操作。缺省情况下，策略拒绝对某个资源的访问

4. Principal键定义策略允许或拒绝访问资源的用户

```json
{ 
  "Version": "2021-03-10", 
  "Statement ": [ 
    { 
      "Effect": "Allow", 
      "Principal": { 
        "AWS" : ["arn:aws:iarm::testaccount:user/testuser"] 
      }, 
      "Action" : "s3:ListBucket", 
      "Resource": [ 
      "arn:aws:s3:::testbucket"
      ]
     }
    ]
}
```

##### 支持S3 MFA删除

RADOS网关服务支持使用Time-based、One-time Password (TOTP)密码作为鉴权因素删除S3 MFA。
该特性增加了安全性，防止不适当的和未经授权的数据删除。除了标准的S3鉴权外，还可以配置桶要求一次性TOTP令牌来删除数据。
删除对象时，桶的所有者必须在HTTPS协议中包含包含认证设备序列号和认证码的请求头，才能永久删除对象版本或改变桶的版本状态。
没有报头，请求将失败

##### 使用REST API创建新的IAM策略和角色

IAM(身份和访问管理)角色的REST APls和用户策略现在可以在与S3 AP相同的命名空间中使用，并且可以在Ceph对象网关中使用与S3 AP相同的端点访问。
该特性允许最终用户通过使用REST apl创建新的1AM策略和角色

##### Ceph对象网关对Amazon S3资源的支持

AWS提供安全令牌服务(STS)，以允许与现有的OpenlD连接进行安全联合;符合OAuth 2.0的身份服务，如Keycloak。
STS是一个独立的REST服务，它为应用程序或用户在对身份提供者进行身份验证后访问S3端点提供临时令牌。
以前，没有永久Amazon Web服务(AWS)凭证的用户无法通过Ceph对象网关访问S3资源

Ceph Object Gateway实现了STS api的一个子集，它为身份和访问管理提供临时凭证。
这些临时凭证可用于进行后续的S3调用，这些调用将由RGW中的STS引擎进行身份验证。
可以通过作为参数传递给STS api的IAM策略进一步限制临时凭证的权限，Ceph Object Gateway支持STS sumeRoleWithWebIdentity

### 9.2 通过Swift接口提供对象存储

#### 9.2.1 在RADOS网关中的OpenStack Swift支持

通过OpenStack Swift接口，开发人员可以通过Swift兼容接口管理对象存储资源。
使用S3 API实现的应用程序可以与除RADOS网关之外的其他兼容swift的对象存储服务互操作，并将存储从其他位置迁移到Ceph存储集群。
在混合云环境下，可以配置自己的应用，通过相同的API，将私有企业OpenStack或独立的Swift资源与公有云OpenStack资源和存储位置无缝混合。
OpenStack Swift API是Amazon S3 API的替代方案通过RADOS网关访问存储在Red Hat Ceph存储集群中的对象。
OpenStack Swift和Amazon S3 API之间有重要的区别

OpenStack Swift指的是将对象存储为容器的命名空间

OpenStack Swift API的用户模型与Amazon S3 API不同。
使用OpenStack Swift接口使用RADOS Gateway进行认证时，需要为自己的RADOS Gateway用户配置子用户

#### 9.2.2 为OpenStack Swift创建Subuser

 Amazon S3 API授权和身份验证模型采用单层设计。
一个用户帐户可能有多个访问密钥和秘密，用户可以使用这些密钥和秘密来提供不同类型的访问OpenStack Swift API但是，它采用多层设计，用于容纳租户和分配的用户。
Swift租户拥有服务使用的存储空间及其容器。快速用户分配给服务，并且对租户拥有的存储具有不同级别的访问权限

适应OpenStack Swift API在认证和授权模型中，RADOS网关引入了子用户的概念。
这个模型允许Swift API将租户作为RADOS Gateway用户和Swift API用户作为RADOS Gateway的子用户处理，Swift API tenant:user 映射到RADOS网关认证系统为user:subuser，为每个Swift用户创建一个子用户，它与一个RADOS网关用户和一个接入密钥相关联

使用radosgw-admin subuser create命令创建子用户，如下所示:

```bash
[ceph: root@node /]# radosgw-admin subuser create \
	--uid=username \
	--subuser=username:swift \
	--access=full
```

--access选项设置用户权限(read、write、read/write、full)， --uid指定现有关联的RADOS Gateway用户。
使用命令radosgw- admin key create

使用--key-type=swift选项创建与子子用户关联的swift身份验证密钥

```bash
[ceph: root@node /]# radosgw-admin key create \
	--subuser=username:swift \
	--key-type=swift
```

当Swift客户端与RADOS网关通信时，后者既是数据服务器，也是Swift认证守护进程(使用/auth URL路径)。
RADOS Gateway同时支持内部Swift(1.0版本)和OpenStack Keystone(2.0版本)的认证

使用- K指定的密钥是用Swift密钥创建的密钥

确保命令行参数不被任何操作系统环境变量覆盖或影响。
如果使用的是Auth 1.0版本，那么使用ST_ Auth、ST_ USER和ST_ KEY环境变量。
如果使用Auth 2.0版本，那么使用OS_ Auth_URL, OS_ USERNAME, OS_ PASSWORD，OS_ TENANT_NAME、OS_ TENANT_ID环境变量

在Swift API中，容器是对象的集合。
Swift API中的对象是存储在Swift中的二进制大对象(blob)。

使用Swift API验证RADOS Gateway可访问性，使用Swift post命令创建容器

```bash
[root@node -]$ swift \
	-A http://host/auth \
	-u username:swift \
	-K secret \
	post container-name
```

上传文件到容器，使用swift upload命令

```bash
[root@node -]$ swift \
	-A http://host/auth \
	-U username:swift \
	-K secret \
	upload container-name file-name
```

如果使用绝对路径来定义文件位置，则对象的名称包含文件的路径，包括斜杠/。例如，下面的命令将/etc/hosts文件上传至services桶

```bash
[root@node -]$ swift \
	-A http://host/auth/ \
	-U user:swift \
	-K secret \
	upload services /etc/hosts
```

在本例中，上传的对象名称为etc/hosts。可以使用- -object-name选项定义对象名称

使用download命令下载文件

```bash
[root@node -]$ swift \
	-A http://host/auth \
	-U username:swift \
	-K secret \
	download container-name object-name 
```

#### 9.2.3 管理Ceph对象网关子用户

使用radosgw-admin subuser Modify命令修改用户的访问级别。
访问级别将用户权限设置为读、写、读/写和完全

```bash
[root@node -]$ radosgw-admin subuser modify \
	--subuser=uid:_subuserid_ \
	--access=access-level
```

使用radosgw-admin subuser rm命令移除用户。
--purge-data选项清除与子用户相关的所有数据，而- -purge- keys选项清除所有子用户key

```bash
[root@node -]$ radosgw-admin subuser rm \
	--subuser=uid:_subuserid_ \
	[--purge-data] \
	[--purge-keys] 
```

可以通过radosgw-admin key命令对子密钥进行管理。
本例创建子用户key

```bash
[root@node -]$ radosgw-admin key create \
	--subuser=uid:_subuserid_ \
	--key-type=swift \
	[--access-key=access-key] \
	[--secret-key=secret-key] 
```

key-type选项只允许swift或s3的值。
如果需要手动指定S3的访问密钥，请使用--access-key;如果需要手动指定S3或Swift的密钥，请使用--secret-key。
如果没有指定访问密钥和秘密密钥，radosgw-admin命令会自动生成它们并显示在输出中，
或者，使用--gen-access-key选项只生成一个随机访问密钥，或者使用--gen-secret选项只生成一个随机密钥

可以使用radosgw-admin key rm命令删除子密钥

```bash
[root@node -]$ radosgw-admin key rm \
	--subuser=uid:subuserid
```

#### 9.2.4 Swift容器对象版本控制和过期

Swift API支持容器的对象版本控制，提供了在容器中保持一个对象的多个版本的能力。
对象版本控制可以避免意外的对象覆盖和删除，并存档以前的对象版本。
Swift API只有在对象内容发生变化时才会在版本化容器中创建一个新的对象版本。

要在容器上启用版本控制，请将容器标志的值设置为存储版本的容器的名称。
在创建新容器或更新现有容器的元数据时设置该标志

对于每个要进行版本控制的容器，应该使用不同的存档容器。
不建议在存档容器上启用版本控制

Swift API支持两个版本标记的头键，X-History-Location或X- versions - Location，它们决定了Swift API处理对象DELETE操作的方式

设置了X-History- Location标志后，在删除容器内的对象后会收到404 Not Found错误。
Swift将对象复制到存档容器中，并在版本化容器中删除原始副本。可以从归档容器中恢复对象

通过设置X-Versions-Location标志，Swift可以在版本化容器中移除当前对象的版本。
然后，Swift将归档容器中最近的对象版本复制到版本化容器中，并从归档容器中删除最近的对象版本

要从设置了X-Versions- Location标志的版本化容器中完全删除一个对象，必须在存档容器中有多少个可用的对象版本就删除多少次

在一个OpenStack Swift容器中，只能同时设置其中一个标志。
如果容器的元数据包含这两个标志，则发出400 Bad Request错误

RADOS Gateway支持Swift API对象版本特性。
要在RADOS网关中激活该特性，在/etc/ceph/ceph.conf配置文件中[client .radosgw.radosgw-name]中设置rgw_swift versioning_enabled为true

在使用Swift API添加对象时，RADOS网关还支持使用X-Delete-AT和X-Delete-After header。
在报头指定的时间，RADOS网关停止服务该对象，并在不久后删除它

#### 9.2.5 在Swift中支持多租户

OpenStack Swift API支持租户隔离桶和用户。
Swift API将用户创建的每个新桶与租户关联。
该特性允许在不同的租户上使用相同的桶名，因为租户可以隔离资源。
为了向后兼容，对于没有关联租户的容器，Swift API使用一个通用的、无名称的租户。

在“RADOS Gateway”中使用radosgw-admin命令配置Swift API租户。
该命令需要一个租户创建使用- -tenant选项提供的用户。

```bash
[root@node -]$ radosgw-admin user create \
	--tenant testtenant \
	--uid testuser \
	--display-name "Swift User" \
	--subuser testswift:testuser \
	--key-type swift \
	--access full
```

任何对子用户的进一步引用都必须包括租户

```bash
[root@node -)$ radosgw-admin \
--subuser 'testtenant$testswift:testuser' \
--key-type swift \
--secret redhat 
```
## 10. 使用 CephFS 提供文件存储

### 10.1 部署共享文件存储

#### 10.1.1 Ceph文件系统和MDS

Ceph文件系统(cepphfs)是一个posix兼容的文件系统，构建在RADOS (Ceph的分布式对象存储)之上。
基于文件的存储像传统的文件系统一样组织数据，具有目录树层次结构。Ceph文件系统的实现需要一个运行的Ceph存储集群和至少一个MDS (Ceph Metadata Server)来管理Ceph文件系统的元数据，与文件数据分开管理，降低了复杂性，提高了可靠性。与RBD和RGW类似，CephFS守护进程是作为librados的本地接口实现的

##### 文件、块和对象存储

基于文件的存储像传统的文件系统一样组织数据。数据保存为具有名称和相关元数据(如修改时间戳、所有者和访问权限)的文件。基于文件的存储使用目录树层次结构来组织文件的存储方式

基于块的存储提供了一个存储卷，它的操作类似于磁盘设备，组织成大小相同的块。通常，基于块的存储卷要么用文件系统格式化，要么由数据库等应用程序直接访问和写入

使用基于对象的存储，可以将任意数据和元数据作为一个单元存储在平面存储池中，该单元使用惟一标识符进行标记。与以块或文件系统层次结构访问数据不同，您使用API存储和检索对象。基本上，Red Hat Ceph Storage RADOS集群是一个对象存储

##### 元数据服务器

元数据服务器(MDS)为CephFS客户端管理元数据。这个守护进程提供cepphfs客户端访问RADOS对象所需的信息，例如提供文件系统树中的文件位置。MDS用于在RADOS集群中管理目录层次结构，存储文件元数据，如所有者、时间戳、权限模式等。MDS还负责访问缓存和管理客户端缓存，以保持缓存一致性。

MDS进程有主备两种运行模式。一个主MDS管理cepphfs文件系统的元数据。备MDS作为备份，当主MDS无响应时切换为主MDS。CephFS共享文件系统需要主MDS服务。应该在集群中至少部署一个备MDS，以确保高可用性

如果没有创建足够的MDS池来匹配配置的备用守护进程的数量，那么Ceph集群将显示WARN健康状态。推荐的解决方案是创建更多的MDS池，为每个守护进程提供一个池。但是，一个临时的解决方案是将备用池的数量设置为0，通过Ceph fs set fs-name standby_count_wanted 0命令禁用Ceph MDS备用检查

CephFS客户端首先联系一个MON来验证和检索集群映射。然后客户端向一个主MDS查询文件元数据。客户端使用元数据通过直接与osd通信来访问组成请求文件或目录的对象。

MDS的特性和配置项说明如下:

**MDS Ranks**

MDS级别定义如何在MDS守护进程上分布元数据工作负载。rank的数量由max_mds配置设置定义，它是一次可以活动的mds守护进程的最大数量。MDS守护进程启动时没有级别，MON守护进程负责为它们分配级别

**Subvolume和Subvolume group**

CephFS子卷是独立的CephFS文件系统目录树的抽象。在创建子卷时，可以指定更细粒度的权限管理，如UID、GID、文件模式、大小和子卷组。子卷组是跨一组子卷的目录级别的抽象

可以创建子卷的快照，但Red Hat Ceph $torage 5不支持创建子卷组的快照。可以列出和删除子卷组的现有快照

**文件系统的亲和力**

将CephFS文件系统配置为使用一个MDS而不是另一个MDS。例如，可以配置为更喜欢运行在更快的服务器上的MDS，而不是运行在旧服务器上的另一个MDS。这个文件系统亲和性是通过mds_join_fs选项配置的

**MDS缓存大小限制**

通过MDS_cache_ memory_limit选项来限制可以使用的最大内存，或者通过mds_cache_size选项定义最大索引节点数来限制MDS缓存的大小

**配额**

配置cepphfs文件系统，通过使用配额来限制存储的字节或文件的数量。FUSE和内核客户机都支持在挂载cepphfs文件系统时检查配额。当用户达到配额限制时，这些客户端还负责停止向CephFS文件系统写入数据。使用setfatr命令的ceph.quota.max_bytes和ceph.quota.max_files选项设置限制。

##### 新的CephFS能力

Red Hat Ceph Storage 5消除了早期版本的限制。

Red Hat Ceph Storage 5支持集群内多个主MDS，提升元数据性能。为了保持高可用性，您可以配置额外的备MDS，当主MDS出现故障时，可以接管其工作。Red Hat Ceph Storage 5支持在集群中创建多个cepphfs文件系统。部署多个cepphfs文件系统需要运行更多的MDS守护进程。

#### 10.1.2 部署CephFS

要实现cepphfs文件系统，需要创建所需的池、创建cepphfs文件系统、部署MDS守护进程，然后挂载文件系统。可以手动创建池，创建ceph fs文件系统，并部署MDS守护进程，或者使用ceph fs卷创建命令，它自动执行所有这些步骤。第一个选项为系统管理员提供了对进程的更多控制，但是比更简单的ceph fs卷创建命令有更多的步骤

##### 使用Volume方法创建CephFS

使用ceph fs卷直接创建ceph fs卷。该命令创建与CephFS相关联的池，创建CephFS卷，并在主机上启动MDS服务

```bash
[ceph: root@server /]# ceph fs volume create fs-name \
	--placement="number-of-hosts list-of-hosts"
```

##### 创建带有放置规范的CephFS

要对部署过程进行更多控制，请手动创建与CephFS关联的池，在主机上启动MDS服务，并创建CephFS文件系统

##### 创建数据池和元数据池

一个cepphfs文件系统至少需要两个池，一个存储cepphfs数据，另一个存储cepphfs元数据。这两个池的默认名称是cephfs_data和cephfs_metadata。要创建cepphfs文件系统，首先创建两个池

```bash
[ceph: root@server /]# ceph osd pool create cephfs_data 
[ceph: root@server /]# ceph osd pool create cephfs_metadata 
```

这个例子创建了两个带有标准参数的池。由于元数据池存储文件位置信息，因此请考虑为该池设置更高的复制级别，以避免导致数据不可访问的数据错误。

默认情况下，Ceph使用复制的数据池。但是，cepphfs文件系统现在也支持erasure-coded的数据池。使用ceph osd pool命令创建一个erasure-coded池

```bash
[ceph: root@server /]# ceph osd pool create pool-name erasure
```

##### 创建CephFS和部署MDS服务

当有可用的数据池和元数据池时，使用ceph fs new命令创建文件系统，如下所示

```bash
[ceph: root@server /]# ceph fs new fs-name metadata-pool data-pool
```

要在ceph fs文件系统中添加一个现有的erasure pool作为数据池，请使用ceph fs add_data_pool

```bash
[ceph: root@server /]# ceph fs add_data_pool fs-name data-pool
```

然后可以部署MDS服务

```bash
[ceph: root@server /]# ceph orch apply mds fs-name \
	--placement="number-of-hosts list-of-hosts"
```

##### 使用服务规范创建CephFS

使用Ceph Orchestrator来使用服务规范部署MDS服务。首先，手动创建两个所需的池。然后，创建一个包含服务细节的YAML文件:

```yaml
service_type: mds 
service_id: fs-name 
placements: 
  hosts: 
    - host-name-1 
    - host-name-2
    - ...
```

使用YAML服务规范和ceph orch apply命令部署MDS服务

```bash
[ceph: root@server /]# ceph orch apply -i file-name.yml 
```

最后，使用ceph fs new命令创建ceph fs文件系统

#### 10.1.3 使用CephFS挂载文件系统

可以使用任一可用的客户机挂载CephFS文件系统:

1. 核心客户端

2. FUSE客户机

内核客户端需要Linux内核版本4或更高版本，从RHEL 8开始就可以使用，对于以前的内核版本，应该使用FUSE客户机

这两个客户端各有优缺点。并不是两个客户机都支持所有特性。
例如，内核客户机不支持配额，但是可以更快。
FUSE客户端支持配额和ACLs。必须允许acl与FUSE客户机挂载的CephFS文件系统一起使用它们

##### 通用CephFS客户端配置

要在任意客户机上挂载基于cephfs的文件系统，请在客户机主机上验证以下先决条件：

1. 在客户端主机安装==ceph-common==包，对于FUSE客户端，还需要安装==ceph-fuse==包

2. 检查Ceph配置文件是否存在(/etc/ceph/ceph.cfg)

3. 授权客户端访问cepphfs文件系统

4. 使用[ceph auth get]()命令提取新的授权密钥，并将其复制到客户端主机上的/etc/ceph文件夹

5. 当使用FUSE客户端为非root用户时，需要在/etc/fuse.conf中添加user_allow_other

##### 使用FUSE客户端挂载cephfs

在满足前提条件的情况下，使用FUSE客户端挂载和卸载cephfs文件系统:

```bash
[root@node -]# ceph-fuse [mount-point] [options] 
```

要为特定用户提供密匙环，可以使用--id选项

需要授权客户端访问ceph fs文件系统，使用ceph fs authorize命令

```bash
[ceph: root@server /]# ceph fs authorize fs-name client-name path permissions 
```

使用ceph fs authorize命令，可以为cepphfs文件系统中的不同用户和文件夹提供细粒度的访问控制。可以为cepphfs文件系统中的文件夹设置不同的选项:

**r:** 指定文件夹的读访问权限。如果没有指定其他限制，则还将对子文件夹授予读访问权限

**w:** 指定文件夹的写访问权限。如果没有指定其他限制，则对子文件夹也授予写访问权限

**p:** 除了r和w功能之外，客户端还需要p选项来使用布局或配额

**s:** 除了r和w功能外，客户端还需要s选项来创建快照

此示例允许一个用户读取根文件夹，并提供对/directory文件夹的读、写和快照权限

```bash
[ceph: root@server /]# ceph fs authorize mycephfs \
	client.user \
		/ r \
		/directory rws
```

默认情况下，CephFS FUSE客户端挂载所访问文件系统的根目录(/)。可以使用ceph-fuse - r directory命令挂载特定的目录

在挂载指定目录时，如果该目录在CephFS卷中不存在，则该操作将失败

当配置多个CephFS文件系统时，CephFS FUSE客户端将挂载缺省的CephFS文件系统。要使用不同的文件系统，请使用- -client_fs选项

要使用FUSE客户机准确地挂载CephFS文件系统，可以在/etc/fstab文件中添加以下条目

```bash
host-name:_port_mount-point fuse.ceph ceph.id=myuser,ceph.client_mountpoint=mountpoint,_netdev 0 0
```

使用umount命令卸载文件系统

```bash
[root@node -]# umount mount-point
```

##### 用内核客户端安装CephFS

在使用CephFS内核客户机时，使用以下命令挂载文件系统

```bash
[root@node -)# mount -t ceph [device]:[path] [mount-point] -o [key-value] [other-options] 
```

需要使用ceph fs authorize命令授权客户端访问ceph fs文件系统。使用ceph auth get命令提取客户端密钥，然后将密钥复制到客户端主机的/etc/ceph文件夹

使用CephFS内核客户机，可以从CephFS文件系统挂载特定的子目录

这个示例从CephFS文件系统的根目录挂载一个名为/dir/dir2的目录

```bash
[root@node ~]# mount -t ceph mon1:/dir1/dir2 mount-point
```

可以指定一个由多个以逗号分隔的MONs组成的列表来挂载设备。标准端口(6789)是默认的，或者可以在每个MON的名称后面添加一个冒号和一个非标准的端口号。建议的做法是指定多个MON，以防在挂载文件系统时有些MON处于离线状态

当使用CephFS内核客户端时，其他选项是可用的:

cepphfs内核客户端挂载选项如下：

|            选项            | 描述                                                         |
| :------------------------: | ------------------------------------------------------------ |
|       ==name=name==        | 要使用的Cephx客户机ID。默认为guest                           |
|       ==fs=fs-name==       | 挂载的cepphfs文件系统的名称。如果不提供值，则使用默认文件系统 |
|    secret=secret_value     | 此客户端密钥的值                                             |
| secretfile=secret_key_file | 这个客户机的带有秘钥的文件的路径                             |
|        rsize=bytes         | 以字节为单位指定最大读取大小                                 |
|        wsize=bytes         | 以字节为单位指定最大写大小。默认为none                       |

要使用内核客户端持久化挂载CephFS文件系统，可以在/etc/fstab文件中添加以下条目

```bash
mon1,mon2:/ mount_point ceph name=user1,secretfile=/root/secret,_netdev 0 0
```

使用umount命令卸载文件系统

```bash
[root@node ~]# umount mount_point 
```

##### 删除CephFS

如果需要，可以删除CephFS。但是，首先要备份所有数据，因为删除CephFS文件系统会破坏该文件系统上存储的所有数据。

删除cepphfs的步骤首先是将其标记为down，如下所示

```bash
[ceph: root@server /]# ceph fs set fs-name down true 
```

然后，可以使用下一个命令删除它

```bash
[ceph: root@server /]# ceph fs rm fs-name \
	--yes-i-really-mean-it
```

##### NFS服务器的用户空间实现

Red Hat Ceph Storage 5通过NFS Ganesha从NFS客户端提供对Ceph存储的访问

NFS Ganesha是一个用户空间NFS文件服务器，支持多种协议，如NFSv3、NFSv4.0、NFSv4.1和pNFS。NFS Ganesha使用文件系统抽象层(FSAL)架构，来支持和共享来自多个文件系统或较低级别存储的文件，例如Ceph、Samba、Gluster和Linux文件系统，如XFS

在Red Hat Ceph Storage中，NFS Ganesha使用NFS 4.0或更高协议共享文件。对于cepphfs客户端、OpenStack Manila文件共享服务和其他配置为访问NFS Ganesha服务的Red Hat产品，这个需求是必要的

以下列出了用户空间NFS服务器的优点:

1. 服务器不实现系统调用

2. 更有效地定义和使用缓存

3. 服务故障转移和重新启动更快更容易实现

4. 可以轻松地对用户空间服务进行集群，以获得高可用性

5. 可以使用分布式锁管理(DLM)来支持多个客户机协议

6. 服务器问题的调试更简单，因此不需要创建内核转储

7. 资源管理和性能监控更加简单

可以通过入口服务在现有的cepphfs文件系统上以active-active配置部署NFS Ganesha。这种active-active配置的主要目标是实现负载平衡，并扩展到许多处理更高负载的实例。因此，如果一个节点发生故障，那么集群将所有工作负载重定向到其他节点

系统管理员可以通过CLI部署NFS Ganesha守护进程，或者在启用Cephadm或Rook协调器的情况下自动管理它们

下面列出了在现有NFS服务之上拥有入口服务的优点:

1. 用于访问NFS服务器的虚拟IP

2. 当一个节点故障时，将NFS服务迁移到其他节点，以缩短故障切换时间

3. NFS节点间负载均衡

ingress 实现还没有完全开发完成。它可以部署多个Ganesha实例，并在它们之间平衡负载，但主机之间的故障转移尚未完全实现。这个特性有望在未来的版本中使用

可以使用多个双活NFS Ganesha服务与Pacemaker的高可用性。Pacemaker组件负责所有与集群相关的活动，比如监控集群成员关系、管理服务和资源以及保护集群成员

前提条件是，创建一个ceph文件系统，并在ceph MGR节点上安装nfs-ganesha、nfs-ganesha-ceph、nfs-ganesha-rados-grace和nfs-ganesha-rados-urls

满足先决条件后，启用Ceph MGR NFS模块

```bash
[ceph: root@server /]# ceph mgr module enable nfs 
```

然后，创建NFS Ganesha集群

```bash
[ceph: root@server /]# ceph nfs cluster create cluster-name "node-list" 
```

节点列表是一个以逗号分隔的列表，其中部署了守护进程容器。

接下来，导出cephfs文件系统

```bash
[ceph: root@server /]# ceph nfs export create cephfs fs-name cluster-name pseudo-path 
```

伪路径参数是伪根路径

最后，在客户机节点上挂载导出的CephFS文件系统

```bash
[root@node -]# mount -t nfs -o port=ganesha-port node-name:_pseudo-path_path
```

##### MDS自动扩容

CephFS共享文件系统需要至少一个主MDS服务才能正常运行，需要至少一个备MDS服务才能保证高可用性。MDS自动扩展模块可以确保有足够的MDS守护进程可用

此模块监视级别的数量和备用守护进程的数量，并调整协调器生成的MDS守护进程的数量

使用实例启用MDS自动扩展模块

```bash
[ceph: root@server /]# ceph mgr module enable mds_autoscaler
```

##### 在另一个Ceph集群上复制CephFS

Red Hat Ceph Storage 5支持cepphfs多站点配置，用于两地三中心复制。因此，可以在另一个Red Hat Ceph存储集群上复制cepphfs文件系统。有了这个特性，可以故障转移到辅助CephFS文件系统，并重新启动使用它的应用程序。CephFS文件系统镜像特性需要使用cephfs-mirror

源集群和目标集群都必须使用Red Hat Ceph Storage版本5或更高版本

CephFS镜像特性是基于快照的。第一次快照同步需要将数据从源集群批量传输到远程集群。然后，对于下面的同步，镜像守护进程识别本地快照之间修改的文件，并在远程集群中同步这些文件。这种同步方式不需要查询远端集群(根据本地快照计算文件差异)，只需要将更新后的文件传输到远端集群，比其他需要批量向远端集群传输数据的同步方式速度更快。默认禁用CephFS镜像模块。要配置CephFS的快照镜像，必须在源集群和远程集群上启用mirroring模块:

```bash
[ceph: root@server /]# ceph mgr module enable mirroring 
```

然后，可以在源集群上部署CephFS镜像守护进程:

```bash
[ceph: root@source /]# ceph orch apply cephfs-mirror [node-name]
```

前面的命令在节点名称上部署CephFS镜像守护进程，并创建Ceph用户CephFS -mir镜像。对于每个CephFS对等体，必须在目标集群上创建一个用户

```bash
[ceph: root@target /]# ceph fs authorize fs-name client_ / rwps
```

此时，可以在源集群上启用镜像。指定文件系统必须启用镜像

```bash
[ceph: root@source /]# ceph fs snapshot mirror enable fs-name
```

下一步是准备目标peer。可以使用下一个命令在目标节点中创建对等引导程序

```bash
[ceph: root@target /]# ceph fs snapshot mirror peer_bootstrap create fs-name peer-name site-name
```

可以使用site-name字符串来标识目标存储集群。当目标peer被创建时，你必须从在目标集群上创建对等体导入引导令牌到源集群

```bash
[ceph: root@source /]# ceph fs snapshot mirror peer_bootstrap import fs-name bootstrap-token 

```

最后，使用如下命令在源集群上配置一个快照镜像目录:

```bash
[ceph: root@source /]# ceph fs snapshot mirror add fs-name path 
```

### 10.2 管理共享文件存储

#### 10.2.1 CephFS管理

使用以下命令管理CephFS文件系统

|           动作            | 命令                                                 |
| :-----------------------: | ---------------------------------------------------- |
|       创建文件系统        | [ceph fs new fs-name meta-pool data-pool]()          |
|    列出现有的文件系统     | [ceph fs ls]()                                       |
|       删除文件系统        | [ceph fs rm fs-name [ - -yes -i- really-mean -it]]() |
|    强制MDS进入故障状态    | [ceph mds fail gid/name/role]()                      |
| 声明MDS修复，触发failback | [ceph mds repaired role]()                           |

CephFS提供了检查和修复MDS日志(cephfs-journal-tool)或MDS表(cephfs-table-tool)的工具，以及检查和重建元数据(cephfs-data-scan)的工具

#### 10.2.2 将文件映射到对象

对于故障排除来说，确定存储文件对象的osd是很有用的。目录或0 长度的文件可能在数据池中有任何关联的对象。

这个例子为Ceph中的一个文件检索对象映射信息:

检索文件的inode编号

```bash
[ceph: root@server /]# stat -c %i filepath 
1099511627776
```

将索引节点数转换为十六进制数。使用printf命令的%x格式化输出

```bash
[ceph: root@server /]# printf '%x\n' 1099511627776 
10000000000 
```

这个示例结合了前两个步骤

```bash
[ceph: root@server /]# printf '%x\n' $(stat -c %i filepath) 
```

在RADOS对象列表中搜索十六进制ID。一个大文件可能返回多个对象

```bash
[ceph: root@server /]# rados -p cephfs_data ls | grep 10000000000 
10000000000.00000000
```

检索返回对象的映射信息

```bash
[ceph: root@server /]# ceph osd map cephfs_data 10000000000.00000000 
osdmap e95 pool ' cephfs_data ' {3) object ' 10000000000.00000000 ' -> pg 3.f0b56f30 
(3.30) -> up ( [1,2], pl) acting ( [1,2], pl)
```

将这个输出解释为cephfs_data池(ID 3)的OSD映射的e95映射epoch映射了10000000000.00000000对象放置组3.30，在OSD 1和OSD 2上，OSD 1为主。如果处于up和acting状态的osd不相同，那么这意味着集群正在重新平衡或存在其他问题

#### 10.2.3 控制RADOS文件布局

RADOS布局控制文件如何映射到对象。这些设置存储在CephFS中的虚拟扩展属性(xattrs)中。可以调整设置来控制使用对象的大小和存储它们的位置

布局属性最初是在CephFS文件系统顶部的目录中设置的。您可以手动设置其他目录或文件的布局属性。创建文件时，它会从父目录继承布局属性。如果没有在其父目录中设置布局属性，则使用最近的具有布局属性的祖先目录

文件的布局属性(比如这些例子)使用ceph.file.layout前缀

文件布局属性

|              属性               | 描述                                                         |
| :-----------------------------: | ------------------------------------------------------------ |
|      ceph.file.layout.pool      | Ceph存储文件数据对象的池(通常是cephfs_data)                  |
|  ceph.file.layout.stripe_unit   | 用于文件RAID 0分布的数据块的大小(以字节为单位)               |
|  ceph.file.layout.stripe_count  | 文件数据组成RAID 0“分条”的连续分条单元的个数                 |
|  ceph.file.layout.object_size   | 文件数据以字节为单位分割成RADOS对象(默认为4194304字节，即4mib) |
| ceph.file.layout.pool_namespace | 使用的名称空间(如果有的话)                                   |

ceph.dir.layout前缀标识目录的布局属性

目录布局属性

|              属性              | 描述                                                     |
| :----------------------------: | -------------------------------------------------------- |
|      ceph.di.layout.pool       | 此属性指定Ceph存储目录数据对象的池(通常为cephfs_data)    |
|  ceph.dir.layout.stripe_unit   | 此属性指定一个目录的RAID 0分布数据块的大小(以字节为单位) |
|  ceph.dir.layout.stripe_count  | 该属性指定目录数据组成RAID 0分条的连续分条单元的个数     |
|  ceph.dir.layout.object_size   | 目录数据拆分为RADOS对象，默认为4194304字节，即4mib       |
| ceph.dir.layout.pool_namespace | 这个属性指定使用的名称空间(如果有的话)                   |

getfattr命令显示文件或目录的布局属性

```bash
[ceph: root@server /]# getfattr 
	-n ceph.file.layout file-path 
# file: file-path ceph.file.layout="stripe unit=4194304 stripe count=1 object size=4194304 pool=cephfs_ data"

[ceph: root@server /]# getfattr \
	-n ceph.dir.layout directory-path 
# file : directory-path ceph.dir.layout="stripe unit=4194304 stripe count=1 object_size=4194304 pool=cephfs_data"
```

setfattr命令修改布局属性:

```bash
[ceph: root@server /]# setfattr \
	-n ceph.file.layout.attribute -v value file 
[ceph: root@server /]# setfattr \
	-n ceph.dir.layout.attribute -v value directory 
```

布局属性在数据最初保存到文件时设置。如果父目录的布局属性在文件创建后改变，那么文件的布局属性不会改变。此外，只有当文件为空时，才能更改文件的布局属性

##### 使用情况和统计数据

可以使用虚拟扩展属性来获取有关CephFS文件系统使用的信息。当与目录上的ceph属性名称空间一起使用getfattr命令时，将返回该目录的递归统计信息列表

```bash
[ceph: root@server /]# getfattr -d -m ceph.dir.* directory-path 
file: directory-path 
ceph .dir.entries="l" 
ceph.dir.files="0" 
ceph.dir.rbytes="424617209" 
ceph.dir. rctime="1341146808.804098000" 
ceph.dir.rentries="39623" 
ceph.dir. rfiles="37362" 
ceph.dir.rsubdirs="2261" 
ceph .dir. subdirs="l" 
```

统计数据提供了详细的信息

CephFS统计:

|       属性        | 描述                                                         |
| :---------------: | ------------------------------------------------------------ |
| ceph.dir.entries  | 直接分支的数量                                               |
|  ceph.dir.files   | 目录中常规文件的数量                                         |
|  ceph.dir.rbytes  | 子树中的总文件大小(目录及其所有子目录)                       |
|  ceph.dir.rctime  | 子树中最近的创建时间(从epoch开始的秒数，1970-01-01 00:00:00 UTC) |
| ceph.dir.rentries | 子树的后代数                                                 |
|  ceph.dir.rfiles  | 子树中常规文件的数量                                         |
| ceph.dir.rsubdirs | 子树中的目录数                                               |
| ceph.dir.subdirs  | 目录中的目录数                                               |

#### 10.2.4 管理快照

部署Red Hat Ceph Storage 5时，CephFS默认启用异步快照。这些快照存储在一个名为.snap。在早期的Red Hat Ceph Storage版本中，快照是默认禁用的，因为它们是一个实验特性

##### 创建快照

使用cephfs set为已有的cephfs文件系统创建快照

```bash
[ceph: root@server /]# ceph fs set fs-name allow_new_snaps true 
```

要创建快照，首先在客户机节点上挂载CephFS文件系统。当有多个cepfs文件系统时，使用-o fs=_f s- name选项挂载一个cepfs文件系统。然后，在.snap目录。快照名称为新的子目录名称。该快照包含cepphfs文件系统中所有当前文件的副本

```bash
[root@node -]# mount.ceph server.example.com:/ /mnt/mycephfs 
[root@node -]# mkdir /mnt/mycephfs/.snap/snap-name
```

使用s选项授权客户端为CephFS文件系统创建快照

```bash
[ceph: root@target /)# ceph fs authorize fs-name client path rws
```

如果需要恢复一个文件，请将该文件从快照目录复制到另一个正常目录

```bash
[root@node -]# cp -a .snap/snap-name/file-name .
```

完全恢复快照。快照目录树，将普通条目替换为所选快照的副本

```bash
[root@node -]# rm -rf * 
[root@node -]# cp -a .snap/snap-name/* .
```

如果要丢弃一个快照，请删除对应的目录.snap。即使快照目录不为空，执行rmdir命令也会成功，无需递归执行rm命令

```bash
[root@node -)# rmdir .snap/snap-name
```

##### 调度快照

可以使用CephFS调度快照。nap_schedule模块管理定时快照。可以使用此模块创建和删除快照计划。快照时间表信息存储在cepphfs元数据池中。要创建快照计划，首先在MGR节点上启用快照计划模块

```bash
[ceph: root@server /]# ceph mgr module enable snap_schedule
```

然后，添加新的快照时间表

```bash
[ceph: root@server /)# ceph fs snap-schedule add fs-path time-period [start-time] 
```

如果安装的版本低于Python 3.7，则开始时间字符串必须使用格式%Y-%m -%dT%H: %m: %S。对于Python 3.7或更高版本，可以使用更灵活的日期解析。为使用实例为“/volume”文件夹创建定时快照，使用ceph fs snap- schedule add命令，定时快照的时间间隔为每小时

在客户机节点上，查看.snap文件夹在安装的CephFS

```bash
[root@node -]# ls /mnt/mycephfs/.snap 
scheduled-2021-10-06-08_00_00 
scheduled-2021-10-06-09_00_00 
scheduled-2021-10-06-10_00_00
```

可以使用list选项列出某个路径的快照时间表:

```bash
[ceph: root@server /]# ceph fs snap-schedule list fs-path
```

使用status选项来验证快照计划的详细信息

```bash
[ceph: root@server /]# ceph fs snap-schedule status fs-path 
```

通过指定路径删除快照计划

```bash
[ceph: root@server /]# ceph fs snap-schedule remove fs-path 
```

通过激活和禁用选项可以激活和禁用快照调度。当添加快照时间表时，如果路径存在，则默认激活快照时间表。但是，如果该路径不存在，则将其设置为不活动的，以便稍后在创建该路径时激活它

```bash
[ceph: root@server /]# ceph fs snap-schedule activate/deactivate 
```



## 11. 管理红帽 Ceph 存储集群

### 11.1 执行集群管理和监控

#### 11.1.1 定义Ceph Manager (MGR)

Red Hat Ceph Storage Manager (MGR)的角色是收集集群统计信息

当MGR节点关闭时，客户端I/O操作可以正常地继续，但是对集群统计信息的查询会失败。为每个集群部署至少两个MGRs，以提供高可用性。MGR通常与MON节点运行在相同的主机上，但这不是必需的

在集群中启动的第一个MGR守护进程将成为活动的MGR，而其他所有的MGRs都处于备用状态。如果活动的经理没有在配置的时间间隔内发送信标，则会由一个备用的经理接管。如果需要，可以通过配置mon_mgr _beacon_grace设置来更改信标时间间隔。缺省值是30秒

使用ceph mgr fail 命令手动从主Manager切换到备Manager

使用ceph mgr stat命令查看MGRs的状态

```bash
[ceph: root@node /]# ceph mgr stat 
{ 
"epoch": 32, 
"available": true, 
"active_ name": "mgrl", 
"num_standby": 3 
}
```

##### Ceph MGR 模块

Ceph MGR具有模块化架构。可以根据需要启用或禁用模块，MGR收集集群统计数据，并可将数据传送至外部监察及管理系统

使用[ceph mgr module ls]()命令查看可用的模块和已启用的模块，使用[ceph mgr services]()命令查看特定模块的发布地址，例如Dashboard模块的URL

##### Ceph仪表板模块

Ceph Dashboard通过基于浏览器的用户界面提供集群管理和监控。Dashboard支持查看集群统计数据和警报，并执行所选的集群管理任务。Ceph Dashboard需要一个激活了Dashboard MGR模块的活动的MGR守护进程

Dashboard依靠Prometheus和Grafana服务来显示收集到的监测数据并生成警报。Prometheus是一款开源的监控和警报工具。Grafana是一个开源的统计绘图工具

仪表板支持基于Ceph指标和配置阈值的警报。Prometheus AlertManager组件负责配置、收集和触发警报。警报在仪表板中显示为通知。可以查看最近告警的详细信息，并将告警静音

#### 11.1.2 监控集群健康

可以使用ceph运行状况命令快速验证集群的状态。该命令返回以下状态之一:

1. HEALTH_0K 表示集群运行正常

2. HEALTH_WARN 表示集群处于警告状态。例如，OSD故障，但仍有足够的OSD正常运行

3. HEALTH_ERR 表示集群处于错误状态。例如，一个完整的OSD可能会对集群的功能产生影响

如果Ceph集群处于警告或错误状态，则Ceph运行状况详细信息命令提供额外的详细信息

```bash
[ceph: root@node /]# ceph health detail
```

ceph -w命令显示ceph集群中发生的事件的其他实时监控信息

```bash
[ceph: root@node /)# ceph -w 
```

该命令提供了集群活动的状态，例如以下详细信息:

1. 跨集群的数据均衡

2. 跨集群的副本恢复

3. 擦洗活动

4. osd启停

可以使用[ceph -W cephadm]()命令监控cephadm日志。使用[ceph log last]() cephadm查看最近的日志条目

```bash
[ceph: root@node /]# ceph -W cephadm
```

#### 11.1.3 管理Ceph服务

容器化服务由容器主机系统上的systemd控制。在容器主机系统上执行systemctl命令启动、停止或重新启动集群守护进程。

集群守护进程通过`$daemon`的类型和守护进程`$id`来引用。$daemon的类型为mon、mgr、mds、osd、rgw、rbd-mirror、crash、cephfs-mirror

MON、MGR和RGW守护进程的`$id`是主机名。OSD的守护进程`$id`即为OSD id。MDS的守护进程`$id`是紧跟主机名的文件系统名

使用ceph orch ps命令列出所有集群守护进程。使用--daemon_ type=DAEM0N选项筛选特定守护进程类型

```bash
[ceph: root@node /]# ceph orch ps --daemon_type=osd
```

要停止、启动或重新启动主机上的守护进程，可以使用systemct l命令和守护进程名称

要列出集群主机上所有守护进程的名称，可以运行systemctl list-units命令并搜索ceph

集群fsid位于守护进程名称中。有些服务名称以一个随机的6个字符串结尾，以区分同一主机上相同类型的各个服务

```bash
[root@node ~]# systemctl list-units 'ceph*'
```

使用ceph.target管理集群节点上所有守护进程

```bash
[root@node ~]# systemctl restart ceph.target
```

也可以使用ceph orch命令来管理集群服务。首先，使用ceph orch ls命令获取服务名称。例如，查找集群OSDs的服务名称，重新启动服务

```bash
[ceph: root@node /]# ceph orch ls
```

```bash
[ceph: root@node /)# ceph orch restart osd.default_drive_group
```

可以使用ceph orch daemon命令管理单个集群守护进程

```bash
[ceph: root@node /]# ceph orch daemon restart osd.1
```

#### 11.1.4 电源关闭或重新启动集群

Ceph支持集群标志来控制集群的行为。重启集群或执行集群维护时，必须设置一些标志。可以使用群集标志来限制失败的群集组件的影响或防止群集性能问题。

使用[ceph osd set]()和[ceph osd unset]()命令管理这些标志:

- **noup**
  不要自动将一个正在启动的OSD标记为up。
  如果集群网络遇到延迟问题，osd可以在MON上标记对方为down，然后标记自己为up。这种情况被称为flapping。
  设置noup和nodown的flag，以防止振荡(flapping)

- **nodown**
  nod自己的标志告诉Ceph MON用down状态标记一个停止的OSD。
  在进行维护或关闭集群时使用nodown标志。
  设置nodown标志以防止振荡(flapping)

- **noout**
  noout标志告诉Ceph MON不要从CRUSH map中移除任何osd，这将阻止CRUSH在osd停止时自动重新平衡集群。
  在对集群的子集进行维护时使用noout标志。
  重启osd后清除标志

- **noin**
  noin标志可以防止osd在引导时被标记为in状态。
  该标志防止数据被自动分配给特定的OSD

- **norecover**
  norecover标志阻止恢复操作运行。
  在进行维护或关闭集群时使用norecover标志

- **nobackfill**
  nobackfil标志阻止回填操作运行。在进行维护或集群关闭时使用nobackfil标志

- **norebalance**
  norebalance标志阻止重新平衡操作运行。在进行维护或关闭集群时使用norebalance标志

- **noscrub**
  noscrub标志阻止清除操作运行

- **nodeep-scrub**
  nodeep-scrub标志阻止任何深层清洗操作的运行

##### 集群断电

请执行以下步骤关闭整个集群。

1. 禁止客户端访问集群

2. 在继续之前，确保集群处于健康状态(HEALTH_ OK)，并且所有pg处于active+clean状态

3. 关闭CephFS

4. 设置noout、norecover、norebalance、nobackfill、nodown和pause标志

5. 关闭所有Ceph对象网关(RGW)和iSCSI网关

6. 逐一关闭OSD

7. 逐个关闭MON节点和MGR节点

8. 关闭管理节点

##### 集群加电

集群上电操作步骤如下:

1. 集群节点上电顺序：admin节点、MON节点和MGR节点、OSD节点、MDS节点

2. 清除noout，norecover，norebalance, nobackfill，nodown 和pause 标志

3. 打开Ceph对象网关和iSCSI网关

4. 开启CephFS

#### 11.1.5 监控集群

使用[ceph mon stat]()或[ceph quorum_status -f json-pretty]()命令查看MON仲裁状态

```bash
[ceph: root@node /]# ceph mon stat 
```

```bash
[ceph: root@node /]# ceph quorum_status -f json-pretty
```

也可以在“Dashboard”中查看MONs的状态

##### 查看日志守护进程

可以使用`journalctl -u $daemon@$id`命令查看守护进程日志。
要只显示最近的日志条目，请使用-f选项。
例如，这个示例查看该主机的OSD 10守护进程的日志

```bash
[root@node -]$ journalctl \
	-u ceph-ff97a876-1fd2-11ec-8258-52540000fa0c@osd.10.service
```

Ceph容器为每个守护进程写入单独的日志文件。
通过配置守护进程的log_to_file设置为rue，为每个特定的Ceph守护进程启用日志记录。
这个示例启用了MON节点的日志记录功能

```bash
[ceph: root@node /]# ceph config set mon log_to_file true
```

#### 11.1.6 监控osd

如果集群不健康，Ceph将显示详细的状态报告，其中包含以下信息:

1. osd当前状态(up/down/out/in)

2. OSD近容量限制信息(nearfull/full)

3. 放置组(pg)的当前状态

ceph状态和ceph健康命令报告与空间相关的警告或错误条件。各种ceph osd子命令可以报告osd使用的详细信息、状态和位置信息

##### 分析OSD使用

ceph osd df命令用来查看osd使用统计信息。可使用ceph osd df tree命令查看CRUSH树

```bash
[ceph: root@node /]# ceph osd df 
```

输出信息说明如下表所示:

|  输出列  | 描述                                                         |
| :------: | ------------------------------------------------------------ |
|    ID    | OSD ID                                                       |
|  CLASS   | OSD使用的设备类型(HDD、SDD或NVMe)                            |
|  WEIGHT  | 在crush地图中OSD的权重。<br />默认设置为OSD容量，单位为TB，通过ceph OSD crush reweight命令修改。<br />权重决定了相对于其他OSD，有多少数据被CRUSH到OSD上。<br />例如，两个具有相同权重的osd接收大致相同数量的I/O请求，存储大致相同数量的数据 |
| REWEIGHT | reweight的默认值或ceph osd reweight命令设置的实际值。<br />可以对OSD重新加权，以临时覆盖CRUSH权重 |
|   SIZE   | OSD的总存储容量                                              |
| RAW USE  | OSD的已用存储容量                                            |
|   DATA   | 用户数据占用的OSD容量                                        |
|   OMAP   | BlueFS存储用于存储OMAP (object map)数据，这些数据是存储在RocksDB中的键值对 |
|   META   | 分配的总BlueFS空间，或bluestore_bluefs_min设置的值，以较大的值为准。<br />这是内部的BlueStore元数据，它计算为分配给BlueFS的总空间减去估计的OMAP数据大小 |
|  AVAIL   | OSD上的空闲空间                                              |
|   %USE   | OSD使用的存储容量百分比                                      |
|   VAR    | 高于或低于平均OSD利用率的变化                                |
|   PGS    | OSD上放置组的个数                                            |
|  STATUS  | OSD的状态                                                    |

使用ceph osd perf命令查看osd性能统计信息

```bash
[ceph: root@node /]# ceph osd perf
```

##### 解释OSD状态

基于这两个标志的组合，OSD守护进程可以处于以下四种状态之一:

- **down或up**
  表示守护进程是否正在运行并与MONs通信

- **out或in**
  表示OSD是否参与集群数据放置

正常运行的OSD状态为up and in

如果一个OSD失败，守护进程脱机，集群可能会在短时间内将其报告为停机和正常运行。
这是为了让OSD有机会自己恢复并重新加入集群，避免不必要的恢复流量

例如，短暂的网络中断可能会导致OSD与集群失去通信，并被临时上报为down。
通过mon_ osd_down_out_interval配置选项控制的短时间间隔(默认为5分钟)，集群会报告osd down 和 out。
此时，分配给失败OSD的放置组被迁移到其他OSD

如果失败的OSD恢复up状态，则集群根据新的OSD集合重新分配位置组，并重新平衡集群中的对象

使用[ceph osd set noout]()和[ceph osd unset noout]()命令，在集群上启用或禁用noout标志。
但是，[ceph osd out osd id]()命令会告诉ceph集群忽略某个osd进行数据放置，并将该osd标记为out状态

osd定期(默认为6秒)验证彼此的状态。
默认情况下，它们每120秒向MONs报告一次状态。
如果一个OSD down，其他OSD或mon将无法接收到该down OSD的心跳响应

管理OSD心跳的配置设置如下:

|            配置选项            | 描述                                                         |
| :----------------------------: | ------------------------------------------------------------ |
|     osd_heartbeat_interval     | OSD peer 检查间隔的秒数                                      |
|      osd_heartbeat_grace       | 无响应OSD变为down状态的时间间隔                              |
|   mon_osd_min_down_reporters   | 在MON认为OSD down掉之前上报OSD down掉的peer数                |
|    mon_osd_min_down_reports    | 一个MON认为OSD是down的次数                                   |
| mon_osd_down_out_subtree_limit | 防止CRUSH单元类型(如主机)在失败时被自动标记为out             |
|  osd_mon_report_interval_min   | 一个新启动的OSD必须在这个秒数内向MON报告                     |
|  osd_mon_report_interval_max   | 从OSD到MON上报的最大秒数                                     |
|  osd_mon_heartbeat _interval   | Ceph监测心跳间隔                                             |
|     mon_osd_report_timeout     | 如果OSD没有上报，则MON之前的超时时间(以秒为单位)将其标记为down |

##### 监控OSD容量

Red Hat Ceph Storage提供配置参数，防止由于集群内存储空间不足导致数据丢失。通过设置这些参数，可以在osd存储空间不足时发出告警。

当达到或超过mon_osd_full_ratio设置值时，集群停止接受来自客户端的写请求，并进入HEALTH_ERR状态。
系统默认的满配率为集群可用存储空间的0.95(95%)。
使用全比例来保留足够的空间，以便在osd失败时，仍然有足够的空间使自动恢复成功，而不会耗尽空间。

mon_ osd_nearfull_ratio设置是更保守的限制。
当mon_ osd_nearfull_ratio限制达到或超过该值时，集群进入HEALTH WARN状态。
这是为了提醒需要向集群中添加osd或在达到完全比例之前修复问题。
默认接近满比率为集群可用存储空间的0.85(85%)

mon_osd_backfill_fulll_ratio设置是认为集群osd已满而无法开始回填操作的阈值。系统默认回填满率为集群可用存储空间的90%，即0.90。

使用命令[ceph osd set- full-ratio]()、[ceph osd set-nearfull-ratio]()和[ceph osd set- backfilfull-ratio]()进行设置

```bash
[ceph: root@node /]# ceph osd set-full-ratio .85 
[ceph: root@node /]# ceph osd set-nearfull-ratio .75 
[ceph: root@node /]# ceph osd set-backfillfull-ratio .80 
```

默认的比率设置适用于小型集群，例如本实验室环境中使用的集群。
生产集群通常需要较低的比例

不同的osd可能是满的，也可能是少的，具体取决于哪些对象存储在哪个放置组中。如果你的一些osd已经满了或者满了，而其他的osd还有很多空间，那么你需要分析你的放置组分布和CRUSH map权重

#### 11.1.7 监控放置组

每个放置组(PG)都有一个分配给它的状态字符串，指示其运行状况状态

当所有放置组都处于==active+clean==状态时，集群是健康的。
scrubbing或deep-scrubbing的PG状态也可能发生在健康的群集中，但并不表示有问题

放置组清除是一个后台进程，它通过将对象的大小和其他元数据与其他osd上的副本进行比较并报告不一致的地方来验证数据的一致性

deep-scrubbing是一个资源密集型的过程，它通过使用按位比较来比较数据对象的内容，并重新计算校验和来识别驱动器上的坏扇区

尽管清除操作对于维护健康的集群至关重要，但它们也会对性能产生影响，尤其是深度清除。安排擦洗以避免I/O高峰时间。
暂时用noscrub和nodeep-scub的flag防止擦洗操作

放置组可以有以下状态:

|                  PG 状态                  | 描述                                                         |
| :---------------------------------------: | ------------------------------------------------------------ |
|                 creating                  | 正在进行PG创建                                               |
|                  peering                  | osd正在就PG中对象的当前状态达成一致                          |
|                ==active==                 | 完成对等连接。PG可用于读写请求                               |
|                 ==clean==                 | PG有正确的副本数量，没有流浪副本                             |
|                 degraded                  | PG具有副本数量不正确的对象                                   |
|                recovering                 | 对象正在通过副本进行迁移或同步                               |
|               recovery_wait               | PG正在等待当地或远程的预订                                   |
|                undersized                 | PG被配置为存储比放置组可用的osd更多的副本                    |
|               inconsistent                | 这个PG的副本不一致。PG中的一个或多个副本是不同的，表明PG有某种形式的破坏 |
|                  replay                   | 在OSD崩溃后，PG正在等待客户端重放日志中的操作                |
|                  repair                   | PG计划进行维修                                               |
| backfill、backfill_wait、backfill_toofull | 回填操作正在等待、发生或由于存储空间不足而无法完成           |
|                incomplete                 | PG从历史日志中丢失了可能发生的写入的信息。这可能表明一个OSD已经失败或未启动 |
|                   stale                   | 日志含义PG状态未知(OSD报告超时)                              |
|                 inactive                  | PG已经不活跃太久了                                           |
|                  unclean                  | PG已经不干净太久了                                           |
|                 remapped                  | 当主OSD恢复或回填时，作用集发生了变化，PG临时重新映射到另一组OSD |
|                   down                    | PG离线                                                       |
|                 splitting                 | PG正在被拆分; pg的数量正在增加                               |
|         scrubbing, deep-scrubbing         | 正在进行PG擦洗或深度擦洗操作                                 |

当一个OSD加入放置组后，PG会进入peer状态，以保证所有节点对该OSD的状态达成一致，如果对等体状态完成后，PG还能处理读写请求，则上报活动状态。如果PG对于它的所有对象也有正确的副本数量，那么它报告一个干净的状态。写操作完成后，正常的PG操作状态是active+clean。

当一个对象被写入PG的主OSD时，PG会报告降级状态，直到所有的副本OSD都承认已经写入该对象

回填状态表示数据正在进行复制或迁移，以实现各osd间pg组的再平衡。当在PG中增加一个新的OSD时，为避免网络流量过大，会逐步对该OSD进行对象回填。回填操作采用后台操作，最大限度减少对集群性能的影响

backfill_wait状态表示回填等待中。回填状态表示回填操作正在进行。backfill_too_ful l状态:请求回填，但由于存储空间不足无法完成

标记为不一致的PG可能具有不同于其他副本的副本，在一个或多个副本上检测到不同的数据校验和或元数据大小。Ceph集群中的时钟偏差和损坏的对象内容也会导致PG状态不一致

##### 识别被卡住的安置组

放置组在失败后转换为降级或对等状态。如果放置组长时间处于这些状态之一，则MON将放置组标记为卡住。被卡住的PG可能会处于以下一种或多种状态:

1. inactive 的PG可能会有peer问题

2. unclean 的PG 可能有问题后恢复失败

3. stale PG没有osd报告，这可能表明所有的osd都失败了

4. undersized 的PG没有足够的osd来存储配置的副本数量

MONs使用mon_pg_stuck_threshold参数来决定PG是否已经处于错误状态太久。
该阈值的缺省值是300秒

当拥有特定PG副本的所有osd处于down和out状态时，Ceph将PG标记为stale。
要从失效状态返回，OSD必须被恢复以获得PG副本并开始PG恢复。
如果情况仍然没有解决，PG是不可访问的，如果I/O请求PG挂起

默认情况下，Ceph执行自动恢复。
如果任何pg恢复失败，集群状态继续显示HEALTH_ERR

Ceph可以声明一个osd或PG丢失，这可能会导致数据丢失。
要确定受影响的osd，首先使用ceph运行状况详细信息命令检索集群状态概览。
然后使用[ceph pg dump_stuck OPTION]()命令检查pg的状态

如果有很多pg一直处于对等状态，使用[ceph osd blocked-by]()命令查看正在阻止该osd peer的osd

检查PG使用ceph pg dump | grep pgid或ceph pg query pgid命令。
托管PG的osd显示在方括号([])中。

要将PG标记为丢失，请使用[ceph pg pgid mark_unfound_lost revert | delete]()命令。要将一个OSD标记为丢失，使用[ceph osd lost OSD.ID --yes-i-really-mean-it]()命令。OSD的状态必须为down out

#### 11.1.8 集群升级

使用[ceph orch upgrade]()命令升级您的Red Hat ceph Storage 5集群。

首先，通过运行[cephadm-ansible preflight]()剧本，并将upgrade_cepph_packages选项设置为true来更新cephadm

使用ceph orch upgrade命令升级Red Hat ceph Storage 5集群

首先，更新cephadm通过运行cephadm-ansible preflight playbook与upgrade_cepph_packages选项设置为true

```bash
[root@node ~]# ansible-playbook \
	-i /etc/ansible/hosts/cephadm-preflight.yml \
	--extra-vars "ceph_origin=rhcs upgrade_ceph_packages=true"
```

然后执行ceph orch upgrade start --ceph-version VERSION命令

```bash
[ceph: root@node /]# ceph orch upgrade start \
	--ceph-version 16.2.0-117.el8cp 
```

执行ceph status命令，查询升级进度

```bash
[ceph: root@node /)# ceph status 
... output omitted ... 
progress: 
Upgrade to 16.2.0-115 .el8cp (ls) 
```

不要将使用不同版本的Red Hat Ceph Storage的客户端和集群节点混合在同一个集群中。
客户端包括RADOS网关、iSCSI网关以及其他使用librados、librbd或libceph的应用程序。

在集群升级后，使用ceph versions命令检查是否安装了匹配的版本

```bash
[ceph: root@node /]# ceph versions 
```

#### 11.1.9 使用Balancer模块

Red Hat Ceph Storage提供了一个名为balancer的MGR模块，它可以自动优化PGs在osd之间的放置，以实现均衡分布。该模块也可以手动运行

如果集群的状态不是HEALTH_OK，则不运行balancer模块。
当集群处于健康状态时，它将限制其更改，以便将需要移动的pg数量保持在5%的阈值以下。
配置target_max_misplaced_ratio MGR设置来调整这个阈值:

```bash
[ceph: root@node /]# ceph \
	config set mgr.* target_max_misplaced_ratio .10
```

缺省情况下，balancer模块处于启用状态。使用ceph balancer on和ceph balancer off命令启用或禁用平衡器。

ceph balancer status命令用来查看均衡器状态。

```bash
[ceph: root@node /]# ceph balancer status 
```

##### 自动平衡

自动平衡使用以下模式之一:

- **crush-compat**
  该模式使用compat权集特性来计算和管理CRUSH层次结构中设备的另一组权值。
  平衡器优化这些权重设置值，以较小的增量向上或向下调整它们，以实现与目标分布尽可能接近的分布。
  此模式完全向后兼容旧客户端
  
- **upmap**
  PG upmap模式允许在OSD映射中存储单个OSD的显式PG映射，而正常的CRUSH放置ca除外。
  upmap模式分析PG布局，然后运行所需的pg-upmap-iterns命令来优化PG布局，实现均衡分布

因为这些upmap条目提供了对PG映射的细粒度控制，upmap模式通常能够在osd中平均分配PG，或者如果PG数量是奇数，则可以使用+/-1 PG。

将模式设置为upmap要求所有客户端都是luminous 或更新的。
使用[ceph osd set-require-min-compat-client luminous]()命令设置所需的最小客户端版本

使用[ceph balancer mode upmap]()命令设置均衡模式为upmap

```bash
[ceph: root@node /]# ceph balancer mode upmap
```

使用ceph balancer mode crush- compat命令将均衡器模式设置为crush-compat

```bash
[ceph: root@node /]# ceph balancer mode crush-compat
```

##### 手动平衡

可以手动运行平衡器来控制均衡发生的时间，并在执行之前对平衡器计划进行评估。如果需要手动运行平衡器，可以使用以下命令禁用自动均衡，然后生成并执行一个计划。

1. 评估并为集群的当前分布打分
   
   ```bash
   [ceph: root@node /]# ceph balancer eval
   ```

2. 对特定池的当前分布进行评估和评分
   
   ```bash
   [ceph: root@node /]# ceph balancer eval POOL_NAME 
   ```

3. 生成PG优化计划并为其命名
   
   ```bash
   [ceph: root@node /]# ceph balancer optimize PLAN_NAME
   ```

4. 显示计划的内容
   
   ```bash
   [ceph: root@node /]# ceph balancer show PLAN_NAME
   ```

5. 分析计划执行的预期结果
   
   ```bash
   [ceph: root@node /]# ceph balancer eval PLAN_NAME
   ```

6. 如果您认可预期的结果，那么就执行计划
   
   ```bash
   [ceph: root@node /]# ceph balancer execute PLAN_NAME
   ```

只有在你希望它改善分布时才执行计划。计划执行后被丢弃

使用ceph balancer ls命令显示当前记录的计划

```bash
[ceph: root@node /]# ceph balancer ls
```

使用ceph balancer rm命令删除计划

```bash
[ceph: root@node /]# ceph balancer rm PLAN NAME
```

### 11.2 集群维护操作

#### 11.2.1 添加/移除OSD节点

在集群维护活动期间，集群可以在降级状态下操作和服务客户端。
但增加或移除osd会影响集群性能。
回填操作会导致osd之间的数据传输量过大，导致集群性能下降

在执行集群维护活动之前，评估潜在的性能影响。在添加或移除OSD时，影响集群性能的主要因素如下:

- **客户端负载**
  如果某个OSD所在的池中客户端负载过高，则会对性能和恢复时间造成影响。
  由于写操作需要通过数据复制来实现弹性，写密集型客户端负载会增加集群恢复时间
  
- **节点的能力**
  节点扩容或移除会影响集群恢复时间。
  节点的存储密度也会影响恢复时间。
  例如，36个osd节点的恢复时间比12个osd节点的恢复时间长
- **集群备用容量**
  在移除节点时，请确认有足够的空闲容量，以避免达到完全或接近完全的比例。
  当集群达到全比例时，Ceph会暂停写操作，防止数据丢失
  
- **CRUSH的规则**
  一个Ceph OSD节点映射到至少一个CRUSH等级，并且这个等级通过CRUSH规则映射到至少一个池。
  在添加和删除osd时，每个使用特定CRUSH层次结构的池都会受到性能影响
  
- **池类型**
  复制池使用更多的网络带宽来复制数据副本，而erasure-coded池使用更多的CPU来计算数据和编码块。
  存在的数据副本越多，集群恢复所需的时间就越长。
  例如，具有许多块的擦除编码池比具有较少相同数据副本的复制池需要更长的恢复时间
  
- **节点的硬件**
  具有较高吞吐量特性的节点(如10gbps网络接口和ssd)比具有较低吞吐量特性的节点(如1gbps网络接口和SATA驱动器)恢复速度更快

#### 11.2.2 更换故障的OSD

红帽Ceph存储被设计为自愈。
当存储设备出现故障时，其他osd上多余的数据副本会自动回填，使集群恢复健康状态

当存储设备故障时，OSD状态变为down。
其他集群问题，比如网络错误，也会将OSD标记为关闭。
当OSD关闭时，首先检查物理设备是否故障

更换故障的OSD需要同时更换物理存储设备和软件defined OSD。
当某个OSD故障时，可以替换该物理存储设备，也可以重用该OSD ID或创建新的OSD ID。
重用同一个OSD ID可以避免重新配置CRUSH Map，如果有OSD故障，可以通过Dashboard界面或CLI命令替换该OSD

执行以下步骤检查OSD是否故障

1. 查看集群状态，确认是否有OSD故障
   
   ```bash
   [ceph: root@node /]# ceph health detail 
   ```

2. 识别故障OSD
   
   ```bash
   [ceph: root@node /]# ceph osd tree | grep -i down 
   ```

3. 定位OSD所在的OSD节点
   
   ```bash
   [ceph: root@node /]# ceph osd find osd.OSD_ID
   ```

4. 尝试启动失败的OSD
   
   ```bash
   [ceph: root@node /]# ceph orch daemon start OSD_ID
   ```

如果OSD没有启动，则可能是物理存储设备故障。
使用journalctl命令查看OSD日志，或者使用生产环境中可用的实用程序来验证物理设备是否故障。
如果确认需要更换物理设备，请执行以下步骤。

1. 暂时禁用擦洗
   
   ```bash
   [ceph: root@node /]# 
   	ceph osd set noscrub;
   	ceph osd set nodeep-scrub 
   ```
   
2. 将OSD从集群中移除
   
   ```bash
   [ceph: root@node /]# ceph osd out OSD_ID 
   ```

3. 观察群集事件并验证已启动回填操作
   
   ```bash
   [ceph: root@node /]# ceph -w 
   ```

4. 确认回填进程已经将所有pg从OSD上移走，现在可以安全移除了
   
   ```bash
   [ceph: root@node /]# while ! ceph osd safe-to-destroy osd.OSD_ID; do sleep 1s; done
   ```

5. 当OSD可以安全移除时，更换物理存储设备并销毁OSD。可以选择从设备中删除所有数据、文件系统和分区
   
   ```bash
   [ceph: root@node /]# ceph orch device zap HOST_NAME OSD_ID --force
   ```

通过Dashboard界面或ceph-volume lvm list或ceph osd metadata CLI命令查找当前设备ID

6. 更换故障OSD，使用与故障OSD相同ID的OSD。在继续之前，请确认操作已完成
   
   ```bash
   [ceph: root@node /]# ceph orch osd rm OSD_ID --replace 
   [ceph: root@node /]# ceph orch osd rm status 
   ```

7. 更换物理设备，重建OSD。新的OSD与故障的OSD使用相同的OSD ID，新存储设备的设备路径可能与故障设备不一致，使用ceph orch device ls命令查找新的设备路径
   
   ```bash
   [ceph: root@node /]# ceph orch daemon add osd HOST_NAME:DEVICE PATH
   ```

8. 启动OSD，确认OSD状态正常
   
   ```bash
   [ceph: root@node /]# ceph orch daemon start OSD_ID 
   [ceph: root@node /]# ceph osd tree
   ```

9. 重新启用擦洗
   
   ```bash
   [ceph: root@node /]# ceph osd unset noscrub
   [ceph: root@node /]# ceph osd unset nodeep-scrub
   ```

#### 11.2.3 添加MON

通过执行以下步骤将MON添加到集群:

1. 验证当前MON计数和放置
   
   ```bash
   [ceph: root@node /]# ceph orch ls --service_type=mon 
   ```

2. 向集群中添加新主机
   
   ```bash
   [ceph: root@node /)# ceph cephadm get-pub-key > ~/ceph.pub 
   [ceph: root@node /)# ssh-copy-id -f -i ~/ceph.pub root@HOST_NAME 
   [ceph: root@node /)# ceph orch host add HOST_NAME
   ```

3. 指定MON节点应该运行的主机
   
   ```bash
   [ceph: root@node /)# ceph orch apply mon --placement="NODEl NODE2 NODE3 NODE4"
   ```

使用该命令时需要指定所有MON节点。如果只指定新的MON节点，那么该命令将删除所有其他的MON，使集群只剩下一个MON节点

#### 11.2.4 删除一个MON

使用ceph orch apply mon命令从集群中删除一个mon。指定除要删除的mon外的所有mon

```bash
[ceph: root@node /]# ceph orch apply mon --placement="NODEl NODE2 NODE3"
```

#### 11.2.5 设置主机进入维护模式

使用ceph orch host maintenance命令设置主机进入或退出维护模式。
维护模式停止主机上所有Ceph守护进程。使用可选的--force选项可以绕过警告

```bash
[ceph: root@node /]# ceph orch host maintenance enter HOST_NAME [--force] 
```

维护结束后，退出维护模式

```bash
[ceph: root@node /]# ceph orch host maintenance exit HOST_NAME
```



## 12 调整和故障排除红帽 Ceph 存储

### 12.1 优化红帽Ceph存储性能

#### 12.1.1 定义性能调优

性能调优是裁减系统配置的过程，以便特定的关键应用程序具有最佳的响应时间或吞吐量。
Ceph集群的性能调优有三个指标: 延迟、IOPS(每秒输入输出操作)和吞吐量。

- **延迟**
  磁盘延迟和响应时间是同一件事，这是一种常见的误解。磁盘延迟是设备的一个函数，但是响应时间是整个服务器的一个函数，对于使用旋转盘片的硬盘驱动器，磁盘延迟有两个组成部分:
  - **寻道时间:** 
    在盘片上将磁头定位到正确轨道所花费的时间，通常为0.2到0.8毫秒
  
  - **旋转延迟:** 
    轨道上正确的起始扇区从磁头下经过所需要的额外时间，通常为几毫秒。在磁头定位好之后，驱动器就可以开始从盘片传输数据了。在这一点上，顺序数据传输速率很重要。
    对于固态硬盘(ssd)，等效的度量是存储设备的随机访问延迟，通常小于一毫秒。
    对于非易失性存储器表示驱动器(NVMes)，存储驱动器的随机访问延迟通常以微秒为单位
  
- **每秒操作 (IOPS)**
  系统每秒能处理的读写请求数与存储设备的能力和应用有关。
  当应用程序发出I/O请求时，操作系统将请求传输给设备，并等待直到请求完成。
  作为参考，使用旋转盘片的硬盘的IOPS在50到200之间，
  ssd的IOPS在数千到数十万之间，
  NVMes的IOPS在数十万左右
  
- **吞吐量**
  吞吐量指的是系统每秒可以读取或写入的实际字节数。
  块的大小和数据传输速率会影响吞吐量。磁盘块大小越高，延迟因素衰减得越多。数据传输速率越高，磁盘将数据从其表面传输到缓冲区的速度就越快
  作为参考值，使用旋转盘片的硬盘的吞吐量约为150mb/s, 
  ssd约为500mbp/s, NVMes约为2000mb/s。
  可以测量网络和整个系统的吞吐量，从远程客户端到服务器

##### 调优目标

使用的硬件决定了系统和Ceph集群的性能限制

性能调优的目标是尽可能高效地使用硬件

一个常见的现象是，调优一个特定子系统可能会对另一个子系统的性能产生负面影响。
例如，可以以高吞吐量为代价来优化系统以获得低延迟，因此，在开始调优之前，建立与Ceph集群的预期工作负载一致的目标:

**IOPS优化**

块设备上的工作负载通常是IOPS密集型的，例如OpenStack虚拟机上运行的数据库。典型的部署需要高性能SAS驱动器来存储ssd或NVMe设备上的日志

**吞吐量的优化**

RADOS网关上的工作负载通常是吞吐量密集型的。对象可以存储大量的数据，比如音频和视频内容

**容量优化**

需要以尽可能低的成本存储大量数据的工作负载通常以性能换取价格。选择更便宜和更慢的SATA驱动器是这种工作负载的解决方案

根据工作负载的不同，调优目标应该包括:

1. 减少时延

2. 增加设备侧IOPS

3. 增加块大小

#### 12.1.2 优化Ceph性能

下面的部分描述了调优Ceph的推荐实践

##### Ceph部署

正确规划Ceph集群部署是很重要的。
MONs的性能对于整个集群的性能至关重要。对于大型部署，MONs应该位于专用节点上。为了保证仲裁的正确性，需要奇数个MONs

Ceph设计用于处理大量数据，如果使用正确的硬件并正确地调优集群，则可以提高性能

在集群安装之后，开始持续监视集群，以排除故障并安排维护活动。
尽管Ceph具有显著的自愈能力，但许多类型的故障事件都需要快速通知和人工干预。
如果出现性能问题，请在磁盘、网络和硬件级别进行故障排除。然后，继续诊断RADOS块设备和Ceph RADOS网关

##### OSD的建议

在写BlueStore块数据库和WAL (write-ahead log)时，为了提高效率，建议使用ssd盘或NVMes盘。
OSD的数据、块数据库和WAL可以配置在相同的存储设备上，也可以通过对这些组件使用单独的设备来进行非配置

在典型的部署中，osd使用具有高延迟的传统旋转磁盘，因为它们提供了令人满意的指标，以更低的每兆字节成本满足定义的目标。
默认情况下，BlueStore osd将数据、块数据库和WAL放在同一个块设备上。
但是，可以通过为块数据库和WAL使用单独的低延迟ssd或NVMe设备来最大化效率。
多个块数据库和WALs可以共享同一个SSD或NVMe设备，降低存储基础设施成本

考虑以下SSD规格对预期工作负载的影响:

1. 支持仪式数量的平均故障间隔时间(MTBF)

2. IOPS功能

3. 数据传送速率

4. BUS/ SSD几个功能

当一个承载日志的SSD或NVMe设备失效时，每个使用它来承载日志的OSD也将不可用。在决定在同一存储设备上放置多少块数据库或WALs时，请考虑这一点

##### Ceph RADOS网关的建议

RADOS网关上的工作负载通常是吞吐量密集型的。
作为对象存储的音频和视频材料可能很大。但是，桶索引池通常显示更I/O密集型的工作负载模式。将索引池存储在SSD设备上。

RADOS网关为每个桶维护一个索引。
默认情况下，Ceph将这个索引存储在一个RADOS对象中。当一个桶存储超过100,000个对象时，单个索引对象成为瓶颈，索引性能下降。

Ceph可以在多个RADOS对象或分片中保存大索引。通过设置rgw_override_bucket_index_max可启用该特性。建议为每桶中预期的对象数除以100,000

随着索引的增长，Ceph必须定期重新共享桶。Red Hat Ceph Storage提供了桶索引自动重分片功能。rgw_dynamic_resharding参数(默认为true)控制该特性

##### CephFS的建议

保存目录结构和其他索引的元数据池可能成为CephFS瓶颈。
为了最大限度地减少这种限制，元数据池使用SSD设备

每个MDS在内存中为不同类型的项(如inode)维护一个缓存。Ceph通过mds_cache_memory_limit参数限制这个缓存的大小。其默认值(以绝对字节表示)为4gb

#### 12.1.3 放置组代数

由于某些OSD节点上不必要的CPU和RAM活动，集群中pg的总数可能会影响整体性能。Red Hat建议在将集群投入生产之前验证每个池的PG分配。还要考虑回填和回收的具体测试，对客户端I/O请求的影响，有两个重要的值:

1. 集群中pg的总数

2. 特定池中可使用的pg数量

使用这个公式来估算一个特定池中可使用的pg数量:

`放置组总数= (OSDs * 100) /副本数量`

应用每个池的公式可以获得集群的pg总数。Red Hat建议每个OSD 100至200 pg

**Splitting PGs**

Ceph支持增加或减少池中pg的数量。
如果在创建池时不指定该值，则创建池时使用默认值==8==pg，这个值非常低

pg_autoscale_mode属性允许Ceph做出建议，并自动调整pg_num和pgp_num参数。在创建新池时，默认启用此选项。pg_num参数定义特定对象的pg数量。pgp_num参数定义CRUSH算法考虑放置的pg的数量。

红帽建议你增加放置组的数量，直到你达到理想的pg数量。大量增加pg的数量会导致集群性能下降，因为会产生预期的数据，重新定位和再平衡是密集的。

使用ceph osd pool set命令通过设置参数pg_num手动增加或减少pg数量。在禁用pg_autoscale模式选项的情况下，手动增加池中的pg数量时，应该只增加少量的增量

将放置组的总数设置为2的幂可以更好地在osd中分布pg。增加pgp_num参数会自动增加pgp_num参数，但会逐步增加，以减少对集群性能的影响

**PG合并**

Red Hat Ceph Storage可以将两个PG合并成一个更大的PG，减少PG的总数。
当池中的pg数量过大且性能下降时，合并可能很有用。因为合并是一个复杂的过程，所以每次只合并一个PG，以尽量减少对集群性能的影响

**PG Auto-scaling**

如前所述，PG自动缩放功能允许Ceph做出建议，并自动调整PG的数量。该特性在创建池时默认启用。对于现有的池，使用这个命令配置自动伸缩:

```bash
[admin@node -)$ ceph osd pool set pool-name pg_autoscale_mode mode
```

将模式参数设置为off以禁用它，设置为on以启用它，并允许Ceph自动调整pg的数量，或在必须调整pg数量时发出警报。

查看自动缩放模块提供的信息:

```bash
[admin@node -)$ ceph osd pool autoscale-status
```

#### 12.1.4 设计集群架构

在设计Ceph集群时，考虑扩展选择，以匹配未来的数据需求，并使用正确的网络大小和体系结构促进足够的吞吐量

##### 可扩展性

可以通过两种方式扩展集群存储:

1. 通过向集群中添加更多节点向外扩展

2. 通过向现有节点添加更多资源进行扩展

扩展要求节点可以接受更多的CPU和RAM资源，以处理磁盘数量和磁盘大小的增加。
向外扩展需要添加具有类似资源和容量的节点，以匹配集群的现有节点，从而实现平衡操作

##### 网络的最佳实践

连接Ceph集群中节点的网络对于良好的性能至关重要，因为所有客户端和I/O集群操作都使用它。红帽公司推荐以下做法:

1. 为了提高性能和提供更好的故障排除隔离，OSD流量和客户端流量使用单独的网络

2. 存储集群的网络容量不小于10gb。1gb组网不适合生产环境

3. 根据集群和客户端流量以及存储的数据量评估网络大小

4. 强烈建议进行网络监控

5. 在可能的情况下，使用单独的网卡连接到网络，或者使用单独的端口

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/tuning/tuning-tuning-cephperf-network.svg)

Ceph守护进程自动绑定到正确的接口，例如将MONs绑定到公共网络，将osd绑定到公共网络和集群网络

#### 12.1.5 手动控制PG的主OSD

使用主亲和性设置来影响Ceph选择一个特定的OSD作为放置组的主OSD。
设置越高，一个OSD被选择为主OSD的可能性越大。
可以通过配置集群来避免主OSD使用慢盘或控制器来缓解问题或瓶颈。ceph osd primary-affinity命令用于修改osd的主亲和性。亲和力是0和1之间的一个实数

```bash
[admin@node -)$ ceph osd primary-affinity osd-number affinity 
```

##### OSD恢复与回填

当Ceph在集群中添加或移除一个OSD时，Ceph会对pg进行重新平衡，使用新的OSD或重新创建存储在被移除的OSD中的副本。
这些回填和恢复操作会产生较高的集群网络流量负载，从而影响性能。

为避免集群性能下降，请调整回填和恢复操作，使重新平衡与集群正常操作之间的关系。
Ceph提供参数来限制回填和回收操作的1/0和网络活动。

以下列表包括其中一些参数:

|            参数             | 定义                                 |
| :-------------------------: | ------------------------------------ |
|  osd_recovery_op_ priority  | 恢复操作优先级                       |
|   osd_recovery_max_active   | 每个OSD的最大并发恢复请求数          |
|    osd_recovery_threads     | 用于数据恢复的线程数                 |
|      osd_max_backfills      | 单个OSD的最大回填数                  |
|    osd_backfill_scan_min    | 每次回填扫描的最小对象数             |
|    osd_backfill_scan_max    | 每次回填扫描的最大对象数             |
|   osd_backfill_full_ratio   | 向OSD回填请求的阈值                  |
| osd_backfill_retry_interval | 在重新尝试回填请求之前，需要等待几秒 |

#### 12.1.6 配置硬件

对集群的预期工作负载使用现实的指标，构建集群的硬件配置，以提供足够的性能，但保持成本尽可能低。
Red Hat建议将这些硬件配置用于以下三个性能优先级:

**IOPS优化**

1. 每个NVMe设备使用两个osd

2. NVMe驱动器将数据、块数据库和WAL配置在同一个存储设备上

3. 假设有一个2ghz的CPU，每个NVMe使用10个核，或者每个SSD使用2个核

4. 分配16gb内存作为基准，每个OSD加5gb内存

5. 每2个osd使用10gbe网卡

**吞吐量的优化**

1. 每个硬盘使用一个OSD

2. 将块数据库和WAL放置在ssd或nvme上

3. 使用至少7200 RPM的硬盘驱动器

4. 假设有一个2ghz的CPU，每个HDD使用半个核

5. 分配16gb内存作为基准，每个OSD加5gb内存

6. 每12个osd使用10个GbE网卡

**容量优化**

1. 每个硬盘使用一个OSD

2. hdd将数据、块数据库和WAL配置在同一个存储设备上

3. 使用至少7200 RPM的硬盘驱动器

4. 假设有一个2ghz的CPU，每个HDD使用半个核

5. 分配16gb内存作为基准，每个OSD加5gb内存

6. 每12个osd使用10个GbE网卡

#### 12.1.7 使用Ceph性能工具进行调优

性能工具提供基准度量来检查集群的性能问题

##### 性能计数器和指标

每个Ceph守护进程都维护一组内部计数器和仪表。有几个工具可以访问这些计数器:

- **仪表板插件**
  Dashboard插件公开了一个可以在端口8443上访问的web界面。
  “集群OSD”菜单提供OSD的基本实时统计信息，如读字节数、写字节数、读操作次数、写操作次数等。
  使用ceph mgr模块Enable Dashboard命令启用Dashboard插件。如果您使用cephadm bootstrap命令引导集群，那么默认情况下仪表板是启用的
- **Manager (MGR) Prometheus 插件**
  该插件在端口9283上公开性能指标，供外部Prometheus服务器收集。Prometheus是一个开源的系统监视和警报工具

- **ceph命令行工具**
  ceph命令具有查看指标和更改守护进程参数的选项

#### 12.1.8 性能压力工具

Red Hat Ceph Storage提供了对Ceph集群进行压力测试和基准测试的工具。

##### RADOS bench命令

RADOS bench是一个简单的测试RADOS对象存储的工具。
它在集群上执行写和读测试，并提供统计数据。
该命令的通用语法如下:

```bash
[admin@node -]$ rados bench \
	 -p POOL-NAME SECONDS write|seq|rand -b objsize -t concurrency
```

以下是该工具的常用参数:

1. seq和rand测试是顺序和随机读取基准测试。这些测试要求首先运行写入基准测试，并使用--no-cleanup选项。
   默认情况下，RADOS平台会删除为编写测试创建的对象。
   --no-cleanup选项将保留这些对象，这对于在相同的对象上执行多个测试非常有用

2. 默认的对象大小是4mb

3. 默认并发数为16

使用--no-cleanup选项，在运行rados bench命令后，必须手动删除池中保留的数据

例如，rados bench命令提供的吞吐量、IOPS、时延信息如下:

```bash
[ceph: root@server /]# rados bench \
	-p testbench 10 write --no-cleanup hints = 1
```

##### RBD bench命令

RBD测试在为测试创建的现有映像上测量I/O的吞吐量和延迟

这些是默认值:

1. 如果不为 size 参数提供后缀，则该命令假定以字节为单位

2. 默认池名为 rbd

3. -io-size 的默认值是 4096 字节

4. --io-threads 的默认值为 16

5. --io-total 的默认值是 1gb

6. --io-mode 的默认值是 seq

例如，rbd bench命令提供的信息包括吞吐量和延迟:

```bash
[ceph: root@server /]# rbd bench \
	--io-type write testimage --pool=testbench 
```

### 12.2 对象存储集群性能调优

#### 12.2.1 维护OSD性能

良好的客户端性能要求在其物理限度内使用OSDs。为了保持OSD性能，评估以下调优机会:

1. 调优OSD使用的BlueStore后端，以便将对象存储在物理设备上

2. 调整自动数据擦洗和深度擦洗的时间表

3. 调整异步快照修整(删除已删除的快照)时间表

4. 控制当OSDs失败或添加或替换时，回填和恢复操作发生的速度

#### 12.2.2 在Ceph BlueStore上存储数据

OSD守护进程的默认后端对象存储是BlueStore。以下列表描述了使用BlueStore的一些主要特性:

**直接管理存储设备**

BlueStore消耗原始块设备或分区。这简化了存储设备的管理，因为不需要其他抽象层，比如本地文件系统

**高效的写时复制**

Ceph块设备和Ceph文件系统快照依赖于在BlueStore中高效实现的写时复制克隆机制。这将为常规快照和依赖克隆实现高效两阶段提交的erasure-coded 池带来高效的I/O

**没有大型双重写入**

BlueStore首先将任何新数据写入块设备上未分配的空间，然后提交一个Roeks DB事务，该事务更新对象元数据以引用磁盘的新区域

**多设备支持**

BlueStore可以使用多个块设备来存储数据、元数据和预写日志

在BlueStore中，原始分区以bluestore_min_alloc_size变量指定的大小块管理。对于hdd和ssd，bluestore_min_alloc_size默认设置为4096，相当于4 KB。如果要写入原始分区的数据小于块大小，那么它将被填充为0。如果块大小不适合工作负载(例如编写许多小对象)，则可能会导致浪费未使用的空间

Red Hat建议设置bluestore_min_alloc_size变量来匹配最小的通用写操作，以避免浪费未使用的空间。例如，如果客户端经常写入4 KB的对象，那么在OSD节点上配置设置，例如bluestore_min_alloc_size = 4096。如果之前用bluestore_min_alloc_size_ssd或bluestore_min_a lloc_size_hdd变量设置了bluetore_min_alloc_size_hdd变量，那么设置bluetore_min_alloc_size变量将覆盖HOD或SSD的特定设置

使用ceph config命令设置bluestore_min_alloc_size变量的值:

```bash
[root@node -]# ceph \
	config set osd.ID bluestore_min_alloc_size_device-type value 
```

#### 12.2.3 BlueStore碎片化工具

随着时间的推移，OSD的空闲空间会变得碎片化。分片正常，但分片过多会降低OSD性能。使用BlueStore时，使用BlueStore碎片化工具检查碎片级别。BlueStore碎片化工具生成一个BlueStore OSD的碎片级别分数。碎片化评分在0 ~ 1之间，0为无碎片化，1为重度碎片化。

作为参考，O和0.7之间的值被认为是小的和可接受的碎片，0.7和0.9之间的分数是可观的，但仍然是安全的碎片，高于0.9的分数表明严重的碎片导致性能问题。

使用BlueStore碎片化工具查看碎片评分:

```bash
[root@node -]# ceph daemon osd.ID bluestore allocator score block
```

#### 12.2.4 维护数据一致性和擦洗

osd负责验证数据一致性，使用轻洗净和深洗净。

- 轻擦洗验证对象的存在、校验和和大小。
- 深度擦洗读取数据并重新计算和验证对象的校验和。

默认情况下，Red Hat Ceph Storage每天执行轻度擦洗，每周执行深度擦洗。
但是，Ceph可以在任何时候开始擦洗操作，这可能会影响集群的性能。
可以使用[ceph osd set noscrub]()和[ceph osd unset noscrub]()命令启用或禁用集群级光擦除。
尽管清除操作会影响性能，但Red Hat建议启用该特性，因为它可以维护数据完整性。
Red Hat建议设置刷洗参数，以将刷洗限制在工作负载最低的已知时间段内

默认配置允许在白天的任何时间轻擦洗

##### 轻擦洗

通过在ceph的[osd]部分添加参数来调整轻刷洗过程。
例如，使用osd_scrub_begin_hour参数来设置时间

扫描开始，从而避免在工作负载高峰期间进行轻度扫描。
轻扫描特性有以下调优参数: osd_scrub_begin_hour = begin_ hour:: begin_ hour参数指定开始扫描的时间。有效值从0到23。如果该值设置为0，且osd_scrub_end_hour也为0，则全天都允许擦洗

- **osd_scrub_end_hour = end_hour**
  end hour参数指定停止擦洗的时间。取值范围为0 ~ 23。如果该值设置为0，并且osd_scrub_begin_hour也为0，那么全天都允许扫描。

- **osd_scrub_load_threshold**
  如果系统负载低于阈值(由get loadavg () / number online CPUs参数定义)，则执行擦洗。默认值为0.5

- **osd scrub_min_interval**
  如果负载低于osd scrub_ load_threshold参数中设置的阈值，执行刷洗的频率不超过该参数中定义的秒数。缺省值为1天

- **osd_scrub_interval_randomize_ratio**
  在参数“osd_scrub min interval ”中定义的值上添加一个随机延迟。默认值为0.5

- **osd_scrub_max_interval**
  无论负载如何，在执行擦洗之前，不要等待超过这个时间。缺省值为7天

- **osd_scrub_priority**
  通过该参数设置擦洗操作的优先级。缺省值为5。该值相对于osd_client_op_priority的值，后者的默认优先级更高，值为63

##### 深层擦洗

[ceph osd set nodeep-scrub]()和[ceph osd unset nodeep-scrub]()命令用于在集群级别启用和禁用深度扫描。可以通过将深度扫描参数添加到ceph配置文件的[osd]部分来配置深度扫描参数。与轻擦洗参数一样，对深擦洗配置的任何更改都会影响集群性能。以下参数是调优深度擦洗最关键的参数:

- **osd_deep_scrub_interval**
  深度擦洗的间隔时间。缺省值为7天

- **osd_scrub_sleep**
  在深度刷洗硬盘读取之间引入暂停。增加该值可以降低擦洗操作的速度，并降低对客户端操作的影响。缺省值为0

可以使用一个外部调度程序来实现轻扫描和深扫描，使用以下命令:

[ceph pg dump]()命令在last_SCRUB和last_DEEP_SCRUB列中显示最后一次轻擦洗和深擦洗

[ceph pg scrub pg-id]()命令在特定的pg上安排深度磨砂

[ceph pg deep-scrub pg-id]()命令在一个特定的pg上安排深磨砂

使用[ceph osd pool set pool-name parameter value]()命令设置指定池的参数

##### 池擦写参数

还可以使用这些池参数在池级控制轻擦洗和深擦洗:

- **noscrub**
  如果设置为true, Ceph不会轻擦洗池。默认值为false

- **nodeep-scrub**
  如果设置为true, Ceph不会深度擦洗池。默认值为false

- **scrub_min_interval**
  擦洗的次数不要超过该参数中定义的秒数。
  如果设置为默认0，则Ceph使用osd_scrub_min_interva l全局配置参数
- **scrub_ max_interval**
  在擦洗池之前，等待的时间不要超过该参数中定义的周期。
  如果设置为默认0, Ceph使用osd_scrub_max_interval全局配置参数

- **deep_ scrub_interval**
  深度擦洗的间隔时间。
  如果设置为默认0, Ceph将使用Osd_deep_scrub_interval全局配置参数

#### 12.2.5 裁剪快照和osd

快照在pool和RBD级别都是可用的。
当删除快照时，Ceph将快照数据的删除安排为异步操作，称为快照修整

为了减少快照修整过程对集群的影响，可以在删除每个快照对象后设置暂停。
通过使用osd snap_trim_sleep参数配置此暂停，该参数是允许下一次快照微调操作之前等待的秒数。该参数的默认值为0。请根据实际环境设置，联系红帽技术支持进行设置

使用osd_snap_trim_priority参数控制快照修剪进程，该参数的默认值为5

#### 12.2.6 控制回填和恢复

为了限制回填和恢复操作对集群的影响，保持集群的性能，有必要对回填和恢复操作进行控制

当有新的OSD加入集群，或者当一个OSD死亡，Ceph将其pg重新分配给其他OSD时，就会进行回填。当发生这样的事件时，Ceph会在可用的osd上创建对象副本

当Ceph OSD变得不可访问并恢复在线时，就会发生恢复，例如由于短时间的中断。OSD进入恢复模式，获取最新的数据副本

可以通过以下参数管理回填和回收操作:

- **osd_rnax_backfills**
  控制每个OSD的最大回填次数。缺省值为1

- **osd_recovery_max_active**
  控制每个OSD的最大并发恢复次数。缺省值为3
- **osd_recovery_op_priority**
  设置恢复优先级。取值范围为1 ~ 63。数字越高，优先级越高。缺省值为3

### 12.3 集群与客户端故障处理

#### 12.3.1 开始故障排除

支持Ceph集群的硬件随着时间的推移会出现故障。集群中的数据变得碎片化，需要维护。应该在集群中执行一致的监视和故障排除，以保持集群处于健康状态

##### 识别问题

在对Ceph问题进行故障排除时，第一步是确定是哪个Ceph组件导致了问题。有时，可以在ceph运行状况detailorceph运行状况status命令提供的信息中找到此组件。其他时候，必须进一步调查以发现问题。验证集群的状态，以帮助确定是单个故障还是整个节点故障

以下故障排除清单建议接下来的步骤:

1. 确定导致问题的Ceph组件

2. 为标识的组件设置调试日志并查看日志

3. 验证拥有一个受支持的配置

4. 确定是否有缓慢或卡住的操作

##### 故障排除集群健康

Red Hat Ceph Storage持续运行各种健康状况检查，以监控集群的健康状况。当运行状况检查失败时，集群运行状况状态将更改为HEALTH_WARN或HEALTH_ERR，具体取决于运行状况检查失败的严重程度和影响。Red Hat Ceph Storage还将健康检查警告和错误记录到集群日志中。ceph status和ceph health命令显示集群运行状况状态。当集群健康状态为HEAL TH_WARN或HEAL TH_ERR时，使用ceph health detail命令查看健康检查消息，以便可以开始对问题进行故障排除

```bash
[ceph: root@node /]# ceph health detail
```

一些运行状况状态消息指示某个特定问题;其他人则提供了更一般的指示。例如，如果群集运行状况状态更改为HEALTH_ WARN，并且看到运行状况消息HEALTH_WARN 1 osds down Degraded data redundancy，那么这就是问题的明确指示

其他运行状况状态消息可能需要进一步的故障排除，因为它们可能指示几个可能的根本原因。例如，以下消息表示一个问题有多种可能的解决方案

```bash
[ceph: root@node /]# ceph health detail
```

可以通过更改指定池的pg num设置来解决这个问题，或者通过重新配置pg autosca ler模式设置从warn变为on，以便Ceph自动调整pg的数量

当集群性能健康状况检查失败时，Ceph会发送有关性能的健康状况消息。例如，OSD之间通过发送心跳ping消息来监控OSD守护进程的可用性。Ceph还使用OSD的ping响应时间来监控网络性能。一个失败的OSD ping消息可能意味着来自某个特定OSD的延迟，表明该OSD存在潜在的问题。多个OSD的ping消息失败可能是网络组件故障，如OSD主机间网络切换

##### 屏蔽Ceph健康警报

可能希望暂时关闭一些集群警告，因为已经知道它们，而且还不需要修复它们。
例如，如果你关闭一个OSD进行维护，那么集群会报告一个HEALTH_WARN状态。可以静音此警告消息，以便健康检查不会影响报告的整体状态。Ceph通过健康检查码指定健康检查警报。例如，前面的HEALTH_ WARN消息显示了POOL_TOO_FEW_PGS运行状况代码。要使运行状况警报消息静音，请使用ceph health命令

```bash
[ceph: root@node /)# ceph health mute health-code [duration]
```

健康代码是ceph health detail命令提供的代码。可选参数duration是静音运行状况消息的时间，以秒、分钟或小时为单位指定。可以使用ceph health unmute heal th-code取消健康信息的静音，当您健康消息设置静音时，如果健康状态进一步降级，Ceph将自动取消警报的静音。例如，如果集群报告一个OSD故障，将该警报设置为静音，如果另一个OSD故障，Ceph将自动移除静音。任何可测量的运行状况警报都将取消静音

#### 12.3.2 配置日志记录

如果集群的某个特定区域出现问题，那么可以为该区域启用日志记录。
例如，如果osd运行正常，但的元数据服务器没有正常运行，请为特定的元数据服务器实例启用调试日志记录。根据需要为每个子系统启用日志记录。向Ceph配置添加调试通常是在运行时临时完成的。如果在启动集群时遇到问题，可以将Ceph调试日志记录添加到Ceph配置数据库中。查看默认路径“/var/log/Ceph”下的Ceph日志文件。Ceph将日志存储在基于内存的缓存中。

##### 理解Ceph日志

在运行时使用Ceph命令配置Ceph日志记录。如果在启动集群时遇到错误，那么可以更新Ceph配置数据库，以便它在启动期间进行日志记录。

您可以为集群中的每个子系统设置不同的日志记录级别。调试级别在1到20之间，其中1表示简洁，20表示详细。

Ceph不发送基于内存的日志到输出日志，除了以下情况:

1. 一个致命的信号出现了

2. 代码中的断言被触发

3. 你的请求

要对输出日志级别和内存级别使用不同的调试级别，请使用斜杠(/)字符。例如，debug_mon = 1/5设置ceph-mon守护进程的输出日志级别为1，内存日志级别为5

##### 在运行时配置日志

要在运行时激活调试输出，请使用ceph tell命令

```bash
[ceph: root@node /]# ceph tell type.id config set debug_subsystem debug-level
```

type和id参数是Ceph守护进程的类型及其id。该子系统为需要修改调试级别的具体子系统

这个例子修改了Ceph组件间消息系统的OSD O调试级别:

```bash
[ceph: root@node /]# ceph tell osd.0 config set debug_ms 5 
```

在运行时查看配置设置如下:

```bash
[ceph: root@node /)# ceph tell osd.0 config show
```

##### 在配置数据库中配置日志

配置子系统调试级别，以便它们在引导时记录到默认日志文件中。使用Ceph config set命令将调试设置添加到Ceph配置数据库中

例如，通过在Ceph配置数据库中设置以下参数，为特定的Ceph守护进程添加调试级别:

```bash
[ceph: root@node /]# ceph config set global debug_ms 1/5 
[ceph: root@node /)# ceph config set osd debug_ms 1 
[ceph: root@node /]# ceph config set osd debug_osd 1/5 
[ceph: root@node /]# ceph config set mon debug_mon 20 
```

##### 设置日志文件轮转

Ceph组件的调试日志是资源密集型的，可以生成大量的数据。如果磁盘几乎满了，那么可以通过修改/etc/logrotate.d/ceph上的日志旋转配置来加速日志轮转，Cron作业调度器使用此文件调度日志轮换

可以在轮转频率之后添加一个大小设置，这样当日志文件达到指定的大小时就会进行轮转:

```bash
rotate 7 
weekly 
size size 
compress 
sharedscripts 
```

使用crontab命令添加一个检查/etc/logrotate.d/ceph文件

```bash
[ceph: root@node /]# crontab -e 
```

例如，可以指示Cron检查/etc/logrotate./ceph每30分钟

```bash
30 * * * * /usr/sbin/logrotate /etc/logrotate.d/ceph > /dev/null 2>&1
```

#### 12.3.3 故障诊断网络问题

Ceph节点使用网络相互通信。当osd被报告为down时，网络问题可能是原因。带有时钟偏差的监视器是网络问题的常见原因。时钟歪斜，或计时歪斜，是同步数字电路系统中的一种现象，在这种现象中，相同的源时钟信号在不同的时间到达不同的元件。如果读数之间的差异与集群中配置的数据相差太远，那么就会出现时钟倾斜错误。该错误可能会导致丢包、延迟或带宽受限，影响集群的性能和稳定性

下面的网络故障排除清单建议下一步步骤:

1. 确保集群中的cluster_network和public_network参数包含正确的值。可以通过使用[ceph config get mon cluster_network]()或[ceph config get mon public_network]()命令检索它们的值，或通过检查ceph.conf文件

2. 检查所有网络接口是否正常

3. 验证Ceph节点，并验证它们能够使用它们的主机名相互连接，如果使用防火墙，确保Ceph节点能够在适当的端口上相互连接。打开适当的端口，如有必要，重新安装端口

4. 验证主机之间的网络连接是否有预期的延迟，并且没有丢包，例如，使用ping命令

5. 连接较慢的节点可能会减慢较快节点的速度。检查交换机间链路是否能够承受已连接节点的累计带宽

6. 验证NTP在集群节点中运行正常。例如，可以查看chronyc tracking命令提供的信息

#### 12.3.4 Ceph客户端故障处理

下面列出了客户端在访问Red Hat Ceph存储集群时遇到的最常见问题:

1. 客户机无法使用监视器(MONs)

2. 使用CLI导致的不正确或缺少命令行参数

3. /etc/ceph/ceph.conf不正确、丢失或不可访问

4. 密钥环文件不正确、丢失或不可访问

ceph-common包为rados、ceph、rbd和radosgw-admin命令提供bash选项卡补全。在shell提示符下输入命令时，可以通过按Tab键来访问选项和属性补全

##### 启用和修改日志文件

在对客户端进行故障诊断时，请提高日志级别

在客户端系统中，可以通过c[eph config set client debug_ms 1]()命令将debug_ms = 1参数添加到配置数据库中。Ceph客户端将调试信息保存在“/var/log/Ceph/Ceph-client.id.log的日志文件

大多数Ceph客户机命令，例如rados、Ceph或rbd，也接受- -debug -ms=1选项，以只执行日志级别增加的命令

##### 启用客户端管理套接字

默认情况下，Ceph客户端在启动时创建一个UNIX域套接字。可以使用此套接字与客户机通信，以检索实时性能数据或动态获取或设置配置参数

在/var/run/ceph/fsid目录中，有该主机的admin套接字列表。允许每个OSD一个管理套接字，每个MON一个套接字，每个MGR一个套接字。管理员可以使用附带- -admin-daemon socket-patch选项的ceph命令查询通过的客户端套接字

```bash
[ceph: root@node /]# sudo ls -al /var/run/ceph/fsid 
```

下面的示例使用FUSE客户端挂载一个CephFS文件系统，获取性能计数器，并将debug_ms配置参数设置为1:

```bash
[root@host ~]# ceph-fuse -n client.admin /mnt/mountpoint

[root@host ~]# ls \
	/var/run/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c
ceph-client.admin.54240.94381967377904.asok
[root@host ~]# ceph --admin-daemon \
	/var/run/ceph/ceph-client.admin.54240.94381967377904.asok \
	perf dump
[root@host ~]# ceph --admin-daemon \
	/var/run/ceph/ceph-client.admin.54240.94381967377904.asok \
	config show
[root@host -]# ceph --admin-daemon \
	/var/run/ceph/ceph-client.admin.54240.94381967377904.asok \
	config set debug_ms 5
[root@host ~]# ceph --admin-daemon \
	/var/run/ceph/ceph-client.admin.54240.94381967377904.asok \
	config show
```

##### 比较Ceph版本和功能

早期版本的Ceph客户端可能无法从已安装的Ceph集群提供的特性中获益。例如，较早的客户机可能无法从erasure-coded池检索数据。因此，在升级Ceph集群时，还应该更新客户机。RADOS网关、用于CephFS的FUSE客户端、librbd或命令行，例如RADOS或RBD，都是Ceph客户端的例子。

在客户端，你可以通过Ceph versions命令找到正在运行的Ceph集群的版本:

```bash
[ceph: root@node /]# ceph versions
```

还可以使用ceph features命令列出支持的特性级别。如果无法升级客户端，[ceph osd set-require-min -compat-client version-name]()指定ceph集群支持的最小客户端版本，使用这个最小的客户端设置，Ceph拒绝使用与当前客户端版本不兼容的特性

使用ceph osd命令验证集群所需的最小版本:

```bash
[ceph: root@node /]# ceph osd get-require-min-compat-client 
luminous 
```

##### 使用Cephx

Red Hat Ceph Storage提供了用于加密认证的cepphx协议。如果启用了Cephx，那么Ceph将在默认的/etc/ceph/路径中查找密钥环。要么为所有组件启用Cephx，要么完全禁用它。Ceph不支持混合设置，比如为客户端启用cepphx，但为Ceph服务之间的通信禁用它。默认情况下，启用了Cephx，当客户端试图访问Ceph集群时，如果没有Cephx，就会收到错误消息

所有Ceph命令都作为客户端进行身份验证。默认为admin用户，但可以使用--name和--ID选项指定用户名或用户ID

Cephx的问题通常与以下方面有关:

1. 对钥匙圈或/etc/ceph/ceph.conf的权限不正确

2. 丢失钥匙圈和/etc/ceph/ceph.conf文件

3. 给定用户的cephx权限不正确或无效。使用ceph认证列表命令来识别问题

4. 不正确或拼写错误的用户名，也可以使用ceph auth list命令来验证

#### 12.3.5 Ceph监视器故障排除

可以通过ceph运行状况详细信息命令或查看ceph日志提供的信息来识别错误消息

以下是最常见的Ceph MON错误消息列表:

**mon.X is down (out of quorum)**

如果Ceph MON守护进程没有运行，则会出现一个错误，阻止该守护进程启动。例如，可能是守护进程有一个损坏的存储，或者/var分区已满。

如果Ceph MON守护进程正在运行，但被报告为关闭，那么原因取决于MON的状态。如果Ceph MON处于探测状态的时间长于预期，那么它就无法找到其他Ceph监视器。这个问题可能是由网络问题引起的，或者Ceph Monitor可能有一个过时的Ceph Monitor map (monmap)试图在不正确的IP地址上到达其他Ceph Monitor。

如果Ceph MON处于e lee ting状态的时间超过预期，那么它的时钟可能不会同步。如果状态从同步变为eleeting，那么这意味着Ceph MON生成映射的速度比同步进程能够处理的速度要快。

如果状态是leader or peon,，那么Ceph Mon已经达到法定人数，但集群的其他成员不承认法定人数。这个问题主要是由时钟故障引起的同步异常、网络故障或NTP同步异常

**clock skew**

这个错误消息表明MON的时钟可能没有被同步。mon_clock_drift_allowed参数控制集群在显示警告消息之前允许的时钟之间的最大差值。主要是由于时钟同步失败、网络故障或NTP同步异常等原因造成的

**mon.X store is getting too big**

当存储太大并延迟对客户端查询的响应时，Ceph MON会显示此警告消息

#### 12.3.6 Ceph OSDs故障处理

使用ceph status命令查看监视器的仲裁。如果群集显示健康状态，则群集可以组成仲裁。如果没有监视器仲裁，或者监视器状态出现错误，请首先解决监视器问题，然后继续验证网络

以下是最常见的Ceph OSD错误消息列表:

- **full osds**

当集群达到mon_osd_full_ratio参数设置的容量时，Ceph返回HEALTH_ERR full osds消息。默认设置为0.95，即集群容量的95%。

使用ceph df命令确定已使用的原始存储的百分比，由% raw used列给出。如果裸存储占比超过70%，则可以删除不必要的数据，或者通过增加OSD来扩展集群来减少裸存储

- **nearfull osds**

当集群达到由mon_osd_nearfull_ratio默认参数设置的容量时，Ceph返回nearfull osds消息。默认值为0.85，即集群容量的85%。

产生此警告消息的主要原因是:

1. 集群OSD间OSD数不均衡

2. 基于OSD数量、用例、每个OSD的目标pg数和OSD利用率，放置组计数不正确

3. 集群使用不成比例的CRUSH可调项

4. osd的后端存储几乎满了

要解决此问题:

1. 验证PG计数是否足够

2. 确认您使用了集群版本最优的CRUSH可调项，如果不是，请调整它们

3. 根据利用率修改osd的权重

4. 确定osd使用的磁盘上剩余的空间

**osds are down**

当osds down或flapping时，Ceph返回osds是down消息。该消息的主要原因是ceph-osd的某个进程故障，或者与其他osd的网络连接出现问题

#### 12.3.7 RADOS网关故障处理

可以排除Ceph RESTful接口和一些常见的RADOS网关问题

##### 调试Ceph RESTful接口

radosgw守护进程是一个Ceph客户端，它位于Ceph集群和HTTP客户端之间。它包括自己的网络服务器Beast，它支持HTTP和HTTPS。

如果发生错误，应该查看/var /log/ceph/文件夹中的日志文件

要将日志记录到文件中，请将log_to_file参数设置为true。可以通过log_file和debug参数更新日志文件的位置和日志级别。还可以在Ceph配置数据库中启用rgw_enable_ops_ log和rgw_ enable_usage_ log参数，分别记录每次成功的RADOS网关操作和使用情况

```bash
[ceph: root@node /]# ceph config set \
	client.rgw log_file /var/log/ceph/ceph-rgw-node.log 
[ceph: root@node /]# ceph config set client.rgw log_to_file true 
[ceph: root@node /]# ceph config set client.rgw debug_rgw 20 
[ceph: root@node /]# ceph config set \
	client.rgw rgw_enable_ops_log true 
[ceph: root@node /)# ceph config set \
	global rgw_enable_usage_log true
```

使用[radosgw-admin log list]()命令查看调试日志。该命令提供可用的日志对象列表。使用[radosgw-admin log show]()命令查看日志文件信息。若要直接从日志对象检索信息，请在对象ID中添加- -object参数。如果要检索具有时间戳的桶的信息，可以添加--bucket、--date和--bucket- ID参数，这些参数分别表示桶名、时间戳和桶ID

##### 常见的RADOS网关问题

在RADOS网关中最常见的错误是客户端和RADOS网关之间的时间倾斜，因为S3协议使用日期和时间来签署每个请求。为了避免这个问题，在Ceph和客户节点上都使用NTP

可以通过在RADOS网关日志文件中查找HTTP状态行来验证RADOS网关请求完成的问题

RADOS网关是一个Ceph客户端，它将所有配置存储在RADOS对象中。保存配置数据的RADOS pg组必须处于active +clean状态。如果状态不是active+clean，那么如果主OSD无法提供数据服务，Ceph I/O请求就会挂起，HTTP客户端最终会超时。使用ceph健康详细信息命令识别未激活的pg

#### 12.3.8 CephFS故障排除

CephFS元数据服务器(MDS)维护一个与其客户端、FUSE或内核共享的缓存，以便MDS可以将其缓存的一部分委托给客户端。
例如，访问inode的客户机可以在本地管理和缓存对该对象的更改。
如果其他客户端也请求访问同一个节点，MDS可以请求第一个客户端用新的元数据更新服务器

为了保持缓存的一致性，MDS需要与客户端建立可靠的网络连接

Ceph可以自动断开或驱逐没有响应的客户端。发生这种情况时，未刷新的客户端数据将丢失

当客户端试图获得对CephFS的访问时，MDS请求具有当前能力的客户端释放它们。如果客户机没有响应，那么CephFS会在超时后显示一条错误消息。可以使用ceph fs set命令使用session_timeout属性配置超时时间。缺省值是60秒

session_autoc丢失属性控制退出。如果客户端与MDS的通信失败时间超过默认的300秒，则MDS将客户端逐出

Ceph暂时禁止被驱逐的客户端，以便他们不能重新连接。如果出现这种禁止，您必须重新引导客户端系统或卸载并重新挂载文件系统才能重新连接



## 13. 使用红帽 Ceph 存储管理云平台

### 13.1 OpenStack存储架构介绍

#### 13.1.1 Red Hat OpenStack平台概述

RHOSP (Red Hat OpenStack Platform)是一个交互服务的集合，控制计算、存储和网络资源。云用户通过自助服务界面使用资源部署虚拟机。云运营商与存储运营商合作，确保为每个使用或向云用户提供存储的OpenStack组件创建、配置和可用的存储空间。

下图给出了一个简单RHOSP安装的核心服务关系的高级概述。所有服务都需要与Keystone (Identity service)进行交互，对用户、服务和权限进行认证后才能进行操作。云用户可以选择使用命令行界面或图形化的Dash查询服务来访问现有资源并创建和部署虚拟机。

Orchestration服务是安装和修改RHOSP云的主要组件。介绍将Ceph集成到OpenStack基础架构中的OpenStack服务

![](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/cloud/OSP-Service-Overview.svg)

##### 介绍存储服务

这些核心OpenStack服务提供多种格式、多种访问方式的存储资源。云用户部署应用虚拟机，使用这些存储资源

- **Compute Service (Nova)**

Compute服务管理运行在hypervisor节点上的虚拟机实例。它使用存储为启动和运行实例提供系统磁盘、交换卷和其他临时磁盘。此服务与Identity服务交互以进行身份验证，即图像

服务来获取映像，以及其他存储服务来访问其他形式的持久性存储以供运行实例使用。Compute服务对hypervisor使用libvirtd、qemu和kvm

- **Block Storage Service (Cinder)**

块存储服务为虚拟机管理存储卷，包括Compute服务管理的实例的临时块存储和持久块存储。该服务实现了用于备份和创建新的块存储卷的快照

- **Image Service (Glance)**

Image服务充当映像的注册表，这些映像在启动时构建实例系统磁盘。活动实例可以保存为映像，供以后使用以构建新实例

- **Shared File Systems Service (Manila)**

共享文件系统服务使用网络基础设施将文件共享作为服务实现。由于云用户通常没有到文件共享服务器的连接权限，因此该服务代理到配置的后端连接。该服务通过NFS和CIFS协议访问文件共享服务器。管理员可以通过配置该服务访问多个文件共享服务器

- **Object Store Service (Swift)**

对象存储(Object Store)为用户以文件的形式上传和检索对象提供存储空间。对象存储体系结构分布在磁盘设备和服务器之间，以实现水平扩展和提供冗余。通常情况下，配置镜像服务使用对象存储服务作为其存储后端，以支持镜像和快照跨对象存储基础设施的复制。该服务还为其他服务提供备份解决方案，将备份结果存储为可检索对象

- **Red Hat Ceph Storage (Ceph)**

Red Hat Ceph Storage是一个分布式数据对象存储，用作所有其他存储服务的后端。Ceph是与OpenStack一起使用的最常见的后端。Ceph集成了OpenStack的计算、块存储、共享文件系统、镜像和对象存储等服务，提供更便捷的存储管理和云扩展性

##### 介绍存储集成服务

这些额外的核心服务提供了实现存储集成所需的overcloud安装、服务容器部署和身份验证支持

- **Identity Service (Keystone)**

Identity服务对所有OpenStack服务进行身份验证和授权。该服务在域和项目中创建和管理用户和角色。该服务提供在OpenStack云中可用的服务及其关联端点的中央目录。Identity服务充当用户和服务组件的单点登录(SSO)身份验证服务。

- **Deployment Service (TripleO)**

部署服务通过Director节点(即OpenStack云)安装、升级和操作OpenStack云

- **Orchestration Service (Heat)**

通过使用Heat编制模板(HOT)文件中定义的资源，编制服务可以提供基础设施和应用程序工作负载。HOT模板和环境文件是部署overclouds的主要配置方法。在redhat OpenStack平台的后续版本中，编排模板和环境文件定义了要部署的服务、资源和体系结构，而Ansible playbook实现了软件供应。

- **Container Deployment Service (Kolla)**

在以后的RHOSP版本中，OpenStack服务是被容器化的。Container Deployment服务为OpenStack服务的运行提供生产状态的容器和配置管理

- **Bare Metal Service (Ironic)**

裸金属发放服务准备和发放物理硬件和KVM虚拟机。该服务与标准和特定于供应商的驱动程序(如PXE和IPMI)一起工作，以与各种硬件通信。

#### 13.1.2 选择Ceph集成体系结构

与基础架构师和网络工程师密切合作的存储操作员，选择支持组织的应用程序用例和规模预测所需的Ceph集成体系结构和服务器节点角色。Ceph可以通过使用两种实现设计中的任意一种集成到OpenStack基础设施中。两个Ceph设计都是由Triple0实现的，它使用Ansible playbook进行大量的软件部署和配置

RHOSP 16.1和16.2只支持RHCS 5作为外部集群。RHOSP 17支持与cephadm一起部署专门的RHCS 5，以取代ceph-ansible

- **Dedicated**

没有现有的独立Ceph集群的组织在RHOSP超云安装过程中安装专门的Ceph集群，该集群由Ceph服务和存储节点组成。只有部署在OpenStack云上的服务和工作负载可以使用专用于openstack的Ceph实现。外部应用程序不能访问或使用openstack专用的Ceph集群存储

- **External**

组织在创建新的OpenStack overcloud时，可以使用现有的独立Ceph集群作为存储。Triple0部署被配置为访问该外部集群在overcloud安装期间创建必要的池、帐户和其他资源。该部署不会创建内部Ceph服务，而是配置OpenStack overcloud作为Ceph客户端访问现有的Ceph集群

一个专用的Ceph集群在RHOSP控制器上运行Ceph控制平面服务时，最多支持750个osd。根据硬件配置的不同，外部Ceph集群可以显著扩大规模。在外部集群上更新和一般维护更容易，因为它们可以独立于RHOSP操作发生。

要维护Red Hat支持，必须用TripleO业务流程服务构建和配置RHOSP安装。对于专用的存储配置，RHOSP 16 TripleO使用相同的RHCS 4 ceph -ansible剧本，这些剧本用于安装独立的ceph集群。但是，由于TripleO动态地组织剧本和环境文件以包括在部署中，所以不支持直接使用Ansible而不支持TripleO

##### 专门的节点实现Ceph角色

一个专用的Ceph实现是Tripleo的默认实现，对于大多数小型、中型和中等规模的OpenStack安装已经足够了。通过使用可组合的节点角色，存储运营商在跨跨云节点的服务分布方面有很多选择。除非另有说明，否则在以后的RHOSP版本中默认包含这些节点角色。下图展示了一个overcloud节点示例，在一个简单的overcloud中实现不同的服务角色

![a](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/cloud/arch-node-roles.svg)

以下节点角色决定了在处理数据平面流量的存储节点和物理存储设备上的服务。默认为cepstorage角色，且控制节点需要安装控制平面业务。

**cepstorage**—最常见的专用Ceph存储节点配置。只包含osd，不包含控制平面服务。

**CephAII**—独立的全存储节点，包含osd和所有控制平面业务。此配置可以与ControllerNoCeph节点角色一起使用

**cepfile**—扩展文件共享的节点。包含osd和MDS服务。

**CephObject** -扩展对象网关访问的节点。包含osd和RGW服务

当存储管理流量增加时，会导致控制节点过载。以下节点角色支持跨多个节点的Ceph控制平面服务的各种配置和分布。协调控制节点角色与存储节点角色选择，确保需要部署的控制平面业务全部部署。控制器—最常见的控制器节点配置。包含所有正常的控制平面服务，包括Ceph MGR、MDS、MON、RBD、RGW服务。**ControllerStorageDashboard**——一个正常的控制器节点加上一个Grafana仪表板服务。该节点角色添加了一个进一步的网络，将存储监控流量与存储后端隔离开来。

**ControllerStorageNFS**—一个正常的控制节点加上一个gananesa服务作为cepfs到NFS的网关。

**ControllerNoCeph**—一个正常的控制器，但没有Ceph控制平面服务。当Ceph控制平面服务移动到独立节点以提高性能和可伸缩性时，将选择此节点角色。

下列节点角色默认情况下不包括在RHOSP发行版中，但在Red Hat在线文档中有描述。通过将主要Ceph服务移动到独立的、专用的节点，使用这些角色来减轻控制节点的过载。这些角色通常出现在存储流量要求较高的大型OpenStack安装中。

**cepmon**—自定义创建的节点角色，只将MON服务从控制器移动到单独的节点。

**CephMDS**—自定义创建的节点角色，只将MDS服务从控制器移动到单独的节点。

**HCI (Hyperconverged Infrastructure)**节点是指计算、存储服务和设备都在同一节点上的配置。这种配置可以提高存储吞吐量大的应用程序的性能。默认是ComputeHCI角色，它只向计算节点添加osd，有效地扩大您的专用Ceph集群。Ceph控制平面服务保留在控制节点上。其他节点角色为超融合节点添加了各种控制平面业务的选择。

**ComputeHCI** -计算节点+ osd。这些节点没有Ceph控制平面服务。

**HciCephAII**—计算节点+ osd和所有Ceph控制平面服务。

**HciCephFile**—计算节点+ osd和MDS服务。用于向外扩展文件共享存储容量。

**HciCephMon**—计算节点+ osd, MON和MGR服务。用于向外扩展块存储容量。

**HciCephObject** -计算节点+ osd + RGW服务。用于向外扩展对象网关访问。

分布式计算节点(DCN)是超融合节点的另一种形式，设计用于属于同一个OpenStack overcloud的远程数据中心或分支机构。为DCN，overcloud部署创建一个专用的Ceph集群，除了主站点上的专用Ceph集群外，每个远程站点至少有三个节点。这种体系结构不是扩展集群配置。后续的DCN版本支持将Glance安装在远程位置，以便更快地访问本地图像。

**DistributedComputeHCI** -一个包含Ceph、Cinder和Glance的DCN节点。

**distributedcomputeciscaleout** -一个DCN节点，包含Ceph, Cinder和针对Glance的HAProxy

##### 实现一个外部的Red Hat Ceph存储集群

RHOSP上云安装有一个undercloud节点，在本文第一个图中称为Director节点。Triple0从Director节点安装overcloud。默认的Triple0业务流程模板在“/usr /share/openstack-Tripleo-heat-templates”目录下。当部署集成了Ceph的OpenStack时，undercloud节点成为Ansible控制器和集群管理主机

下面的叙述提供了Triple0云部署资源的有限视图。您的组织的部署将需要进一步的设计工作，因为每个生产overcloud都有独特的存储需求

由于默认的业务流程文件正在不断增强，所以您一定不能在它们的原始位置修改默认模板文件。相反，应该创建一个目录来存储自定义环境文件和参数覆盖。以下ceph-ansib le-external.yaml环境文件指示Trip le0使用ceph -ansib le客户端角色访问预先存在的外部ceph集群。若要覆盖此文件中的默认设置，请使用自定义参数文件

```yaml
[stack@director ceph-ansible]$ cat ceph-ansible-external.yaml 
resource_registry: 
 OS: :TripleO: : Services: : CephExternal: .. / .. /deployment/ceph-ansible/ceph-external.yaml 
parameter_defaults: 
# NOTE: These example parameters are required when using CephExternal 
#CephClusterFSID: ' 4b5c8c0a-ff60-454b-alb4-9747aa737d19 ' 
#CephClientKey: 'AQDLOh1VgEp6FRAAFzT7Zw+Y9V6JJExQAsRnRQ== ' 
#CephExternalMonHost : ' 172.16.1.7, 172.16.1.8' 
# the following parameters enable Ceph backends for Cinder, Glance, Gnocchi and 
Nova 
 NovaEnableRbdBackend: true 
 CinderEnableRbdBackend: true 
 CinderBackupBackend: ceph 
 GlanceBackend: rbd 
# Uncomment below if enabling legacy telemetry 
# GnocchiBackend: rbd 
# If the Ceph pools which host VMs, Volumes and Images do not match these 
# names OR the client keyring to use is not called ' openstack', edit the 
# following as needed. 
 NovaRbdPoolName: vms 
 CinderRbdPoolName: volumes 
 CinderBackupRbdPoolName: backups 
GlanceRbdPoolName: images 
# Uncomment below if enabling legacy telemetry 
# GnocchiRbdPoolName: metrics 
 CephClientUserName: openstack 
# finally we disable the Cinder LVM backend 
 CinderEnableiscsiBackend: false 
```

TripleO 部署使用[openstack overcloud deploy]()命令指定所有要部署的overcloud服务的环境文件列表。在部署之前，使用[openstack tripleo container image prepare]()命令来确定配置中引用的所有服务，并准备一份校正器容器列表，以便下载并提供给超云部署。在安装过程中，使用Kolla在节点角色定义的正确节点上配置和启动每个服务容器。

对于这个外部Ceph集群示例，TripleO需要一个参数文件来指定真正的集群参数，以覆盖Ceph-ansible-external中的默认参数。yaml文件。这个示例参数-overrides。Yaml文件放置在自定义部署中

文件目录。您可以从适当的ceph认证添加客户端的结果中获得密钥。打开堆栈命令。

```yaml
parameter_defaults: 
# The cluster FSID 
  CephClusterFSID: '4b5c8c0a-ff60-454b-alb4-9747aa737d19' 
# The cephX user auth key 
  CephClientKey: 'AQDLOh1VgEp6FRAAFzT7Zw+Y9V6JJExQAsRnRQ==' 
# The list of Ceph monitors 
  CephExternalMonHost: '172.16.1.7, 172.16.1.8, 172.16.1.9'
```

Trip le0依赖于Bare Metal服务来准备节点，然后将它们安装为Ceph服务器。磁盘设备(包括物理的和虚拟的)必须清除所有分区表和其他工件。否则，Ceph在确定设备正在使用后拒绝覆盖该设备。要从磁盘中删除所有元数据，并创建GPT标签，请在/home/stack/underc文件中设置以下参数。配置文件在云下。每当节点状态设置为可用时，裸金属服务启动节点并清理磁盘

```bash
clean_nodes=true
```

### 13.2 在OpenStack组件中实现存储

#### 13.2.1 OpenStack存储实现概述

在Ceph之前，每个存储组件都使用本地存储，如直接连接的物理磁盘或虚拟磁盘，或网络连接的存储(NAS)或存储区域网络(SAN)硬件。NAS和SAN配置的使用支持控制平面节点可以共享的更大的存储，但这需要额外的物理NI c或主机适配器，限制了控制平面容易扩展的能力。

网络文件系统(NFS)也是跨计算节点和控制节点访问共享存储的有效方法。尽管NFS已经成熟，并且在配置冗余时具有显著的性能和弹性，但它有伸缩性限制，并且不是为云应用程序需求而设计的。OpenStack需要一个可伸缩的云存储解决方案设计

##### 回顾OSP中的Ceph能力

Ceph是一种可扩展的存储解决方案，可以跨商品存储节点复制数据。Ceph采用对象存储架构进行数据存储，并提供对象存储、块存储和文件系统的多个存储接口。

Ceph与OpenStack特性的集成:

1. 支持与Swift对象存储使用相同的API

2. 通过写时复制支持精简配置，使基于卷的配置快速

3. 支持Keystone身份认证，透明集成或替换Swift Object Store

4. 统一对象存储和块存储

5. 支持cepfs分布式文件系统接口

#### 13.2.2 按类型实现存储

每个OpenStack服务都是一个API抽象，隐藏了后端实现。许多服务可以配置多个后端以同时使用。一个服务可以在Ceph中配置多个池，并使用分层或标记标准来透明地选择

适当的存储池。层还可以容纳具有不同性能需求的工作负载。如果在现有集群中实现层，则CRUSH规则更改可能导致池数据的重大移动。

OpenStack服务使用唯一的服务帐号，以服务名称命名。服务帐户代表请求用户或其他服务运行服务操作。在Ceph中为每个需要存储访问的OpenStack服务创建类似的帐户。例如，Image服务被配置为Ceph访问，使用这个命令:

```bash
[admin@node -]# ceph auth get-or-create client.glance \
	mon 'profile rbd' \
	osd 'profile rbd pool=images' \
	mgr ' profile rbd pool=images' 
```

##### Image Storage

在OpenStack中，Image服务的默认后端是一个文件存储，位于控制节点上的Glance API节点上。位置是可配置的，默认为/var/lib/glance。为了提高可伸缩性，Image服务在控制节点的默认/ var/lib/glance/Image-cache/位置实现了一个图像缓存。当Compute服务加载以默认QCOW2格式存储的图像并将其转换为RAW以便在计算节点上使用时，将缓存转换后的图像。

当Red Hat Open Stack Platform安装了Swift Object Store时，Trip leO默认将图像服务后端放在Swift上。Swift服务创建了一个名为glance的容器来存储glance图像。

当Ceph存储集成到RHOSP中时，Trip leO默认将映像服务后端放在Ceph RADOS块设备(RBD)上。Glance映像存储在Ceph池中，称为images。RHOSP将图像作为不可变的blob处理，并相应地处理它们。池名可以通过g lance_pool_name属性进行配置。默认情况下，镜像池被配置为复制池，这意味着所有镜像都跨存储设备进行复制，以实现透明弹性。

映像池可以配置为擦除编码，以节省磁盘空间，同时稍微增加CPU利用率。

当使用Ceph作为存储后端时，禁用图像缓存是很重要的，因为Ceph希望Glance图像以RAW格式存储，所以不需要禁用图像缓存。当使用RAW图像时，所有的图像交互都发生在Ceph中，包括图像克隆和快照创建。

禁用图像缓存可以消除控制节点上重要的CPU和网络活动。

当使用带有分布式计算节点(DCN)的分布式体系结构时，TripleO可以使用每个远程站点上的映像池配置映像服务。您可以在中心(集线器)站点和远程站点之间复制映像。DCN Ceph集群使用RBD技术，如写时拷贝和快照分层，以快速启动实例。镜像、块存储和计算服务都必须配置为使用Ceph RBD作为后端存储

##### Object Storage

对象存储在OpenStack中是通过Swift (Object Store)服务实现的。对象存储服务同时实现了Swift API和Amazon S3 API。默认的存储后端是基于文件的，并在is rv /node的子目录中使用xfs格式的分区挂载在指定存储节点上。您也可以配置对象存储服务，使用现有的外部Swift集群作为后端。

当Ceph存储集成到RHOSP中时，Trip leO配置对象存储服务使用RADOS网关(RGW)作为后端。类似地，Image服务是为RGW配置的，因为Swift不能作为后端使用。

Ceph对象网关可以与Keystone身份服务集成。此集成将RGW配置为使用Identity服务作为用户权限。如果Keystone授权一个用户访问网关，那么该用户也在Ceph对象网关上创建。Keystone验证的身份令牌被Ceph对象网关认为有效。Ceph对象网关也被配置为Keystone中的对象存储端点

##### Block Storage

块存储在OpenStack中是通过Cinder (Block storage service)服务实现的。块存储服务提供持久卷，这些卷保持在存储中，并且在不附加到任何实例的情况下是稳定的。配置块存储服务的常用方法是多个后端。默认的存储后端为LVM (Logical Volume Manager)，配置LVM使用卷组cinder -volumes。Trip leO可以在安装期间创建卷组，也可以使用现有的cinder-volumes卷组。

当Ceph存储集成到RHOSP中时，TripleO配置块存储服务使用RADOS块设备(RBD)作为后端。块存储卷存储在一个称为卷的Ceph池中。卷备份存储在名为backups的Ceph池中。Ceph通过使用libvirt将块设备映像附加到OpenStack实例，该实例将QEMU接口配置到librbd Ceph模块。Ceph条带在集群内的多个osd上块卷，与本地驱动器相比，为大卷提供了更高的性能。

OpenStack的卷、快照、克隆均以块设备的形式实现。OpenStack使用卷启动虚拟机，或将卷作为进一步的应用存储挂载到运行中的虚拟机

#### 13.2.3 File Storage

文件存储在OpenStack中由共享文件系统服务(马尼拉)实现。共享文件系统服务支持多个后端，可以从一个或多个后端提供共享。共享服务器通过使用各种文件系统协议导出文件共享，例如NFS、CIFS、GlusterFS或HDFS。

共享文件系统服务是持久存储，可以挂载到任意数量的客户机上。您可以从一个实例分离文件共享，并将它们附加到另一个实例，而不会丢失数据。共享文件系统服务管理共享属性、访问规则、配额和速率限制。因为没有特权的用户不允许使用mount命令，Shared File Systems服务充当代理来挂载和卸载存储运营商配置的共享。

当Ceph存储集成到RHOSP中时，TripleO配置共享文件系统服务使用cepfs作为后端。cepfs在共享文件系统服务中使用NFS协议。TripleO可以使用Control lerStorageNFS服务器角色配置NFS ganesh集群作为libcephfs后端的可扩展接口

#### 13.2.4 Compute Storage

临时存储在OpenStack中通过计算服务(Nova)实现。Compute服务使用KVM hypervisor和libvirt以虚拟机的形式启动计算工作负载。Compute服务需要两种类型的libvirt操作存储:

**Base image:** 映像服务中的映像的缓存和格式化副本。

**实例覆盖:** 将在基本映像上覆盖的分层卷，作为虚拟机的实例磁盘。

当Ceph存储集成到RHOSP中时，TripleO将计算服务配置为使用RADOS块设备(RBD)作为后端。有了RBD，实例操作系统磁盘既可以作为临时磁盘(在实例关闭时将被删除)管理，也可以作为持久卷管理。临时磁盘的行为与普通磁盘类似，可以列出、格式化、挂载并作为块设备使用。但是，磁盘及其数据不能被保存或访问超出其附加实例的范围

在早期的OpenStack版本中，虚拟机的磁盘出现在hypervisor文件系统的“/var/lib/nova/instances/uuid/”目录下。
早期的Ceph版本只能使用块存储服务boot -from-volume功能启动虚拟机

在最近的版本中，你可以直接引导Ceph中的每个VM，而不需要使用块存储服务。该特性使hypervisor能够在维护操作或硬件故障时使用动态迁移和疏散操作来恢复另一个hypervisor中的虚拟机

### 13.3 介绍OpenShift存储体系结构

#### 13.3.1 Red Hat OpenShift容器平台概述

Kubernetes是一种编排服务，用于部署、管理和扩展容器化应用程序。开发人员可以使用Kubernetes迭代构建应用程序并自动化管理任务。Kubernetes将容器和其他资源包装到Pod中，并将应用程序抽象到单个部署单元中。

Red Hat OpenShift容器平台（RHOCP）是一个模块化组件和服务的集合，构建在Kubernetes容器基础设施之上。OpenShift容器平台提供远程管理、多租户、监控、审核和应用程序生命周期管理。它具有增强的安全功能和自助服务接口。它还与主要红帽产品集成，扩展了平台的功能。

OpenShift容器平台在大多数云中可用，无论是作为托管云服务在公共云中或作为数据中心中的自我管理软件。这些实现提供不同级别的平台自动化、更新策略和操作定制。这里参考了RHOCP 4.8。

OpenShift容器平台通过以下方式分配集群内每个节点的职责：

不同的角色。机器配置池（MCP）是分配角色的主机集。每个MCP管理主机及其配置。控制平面和计算MCP为：由defualt创建。

计算节点负责运行控制平面的计划工作负载，计算节点包含服务，如CR-0（打开的容器运行时接口容器倡议兼容性），以运行、停止或重新启动容器，以及kubelet，它充当代理接受操作容器的请求。

控制平面节点负责运行主要OpenShift服务，例如其中：

OpenShift API服务器。它验证并配置OpenShift资源的数据，例如项目、路线和模板。

OpenShift控制器管理器。它监视etcd服务的资源和用途的变化用于强制指定状态的API。

OpenShift是OAuth API服务器。它将验证和配置数据以验证到OpenShift容器平台，如用户、组和OAuth令牌。

#### 13.3.2 描述Operators 和自定义资源定义

Operator是调用OpenShift控制器API来管理资源的应用程序。

Operators 提供了一种可重复的方式来打包、部署和管理容器化应用程序

Operator容器映像定义了部署的要求，如依赖服务和硬件资源。因为操作员需要资源访问，所以他们通常使用自定义安全设置。Operator为资源管理和服务配置提供API，并提供自动化管理和升级策略。

OpenShift容器平台使用操作员生命周期管理器（OLM）来管理操作员。

OLM协调Operator目录中其他Operator的部署、更新、资源利用和删除。每个运营商都有一个群集服务版本（CSV），该版本描述了Operator运行所需的技术信息，如其所需的RBAC规则及其管理或依赖的资源。OLM本身就是一个运营商。

自定义资源定义（CRD）对象定义集群中的唯一对象类型。自定义资源（CR）对象是从CRD创建的。只有群集管理员才能创建CRD。

具有CRD读取权限的开发人员可以将定义的CR对象类型添加到他们的项目中。

Operator通过将CRD与任何所需的RBAC策略和其他特定于软件的逻辑打包来使用CRD。群集管理员可以独立于

Operator生命周期，可供所有用户使用。

#### 13.3.3 介绍Red Hat OpenShift  Data Foundation  

红帽OpenShift Data Foundation（前身为红帽OpenShift容器存储）是云存储和数据服务的高度集成集合，充当OpenShift集装箱平台的存储控制平面。OpenShift数据基金会作为运营商在Red Hat OpenShift容器平台服务目录中提供。OpenShift数据基础4.8使用红帽Ceph存储4.2。

#### 13.3.4 介绍OpenShift容器存储Operator

OpenShift容器存储operator 将三个operator 集成为一个operator 包，以初始化和管理OpenShift数据基础服务。这三个运营商是OpenShift容器存储（ocs operator ）、Rook Ceph和多云对象网关（NooBaa）。这个

operator 捆绑包包括一个聚合CSV和部署ocs operator 、Rook Ceph和NooBaa operator 所需的所有CRD

##### 描述ocs operator

操作员ocs-操作员初始化OpenShift数据基础服务的任务并执行操作作为Rook Ceph和NooBaa的配置网关。运营商ocs运营商取决于：

在OCS中定义的配置上！CSV中的初始化和存储C/uster CRD捆安装操作员包后，ocs操作员启动并创建

0中国化资源（如果尚未存在）。中国化资源执行基本设置并初始化服务。它创建openshift-storage命名空间

其中其他bundle操作符将创建资源。您可以编辑此资源以调整OpenShift数据基础操作符中包含的工具。如果0中国化资源处于失败状态，进一步的启动请求将被忽略，直到资源被删除。

StorageCluster资源管理Rook、Ceph和NooBaa运营商CRD的创建和协调。这些CRD是由已知的最佳实践和政策定义的：红帽支撑。您可以使用中的安装向导创建StorageCluster资源OpenShift是一个容器平台。



## A. Appendix

### A1. lv-errata

> 默认/根分区太小

**[root@founation]#**

```bash
mv ~kiosk ~root

umount /home

sed -i '/home/d' /etc/fstab

lvremove /dev/rhel_foudation0/home
lvextend /dev/rhel_foundation0/root

xfs_growfs /

mv ~root/kiosk /home
```

### A2. <kbd>Tab</kbd>

**[ceph: root@clienta /]# **

```bash
bash -c "$(curl -s http://content/tab)"
source /etc/profile
```

### A3. Version

> https://access.redhat.com/solutions/2045583
>
> https://docs.ceph.com/en/latest/releases/

- **Red Hat Ceph Storage 5.x**
  *NOTE: RHCS 5 is supported containerized only*

| Upstream Code Name | Downstream Release Name                    | Red Hat Ceph Storage Package Version (RHEL 8.x)              | Red Hat Ceph Storage Package Version (RHEL 9.x)              | Red Hat Ceph Ansible Package Version                         | Cephadm Ansible Package Version | Release Month  | Container Tag                                                |
| :----------------- | :----------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :------------------------------ | :------------- | :----------------------------------------------------------- |
| Pacific            | Red Hat Ceph Storage 5.3.z1 - 5.3.1        | [16.2.10-138.el8cp](https://access.redhat.com/errata/RHSA-2023:0980) | [16.2.10-138.el9cp](https://access.redhat.com/errata/RHSA-2023:0980) | [ceph-ansible-6.0.28.3-1](https://access.redhat.com/errata/RHSA-2023:0076) | cephadm-ansible-1.11.0-1        | Feb, 2023      | [5-404](https://catalog.redhat.com/software/containers/rhceph/rhceph-5-rhel8/60ec72a74a6a2c7844abe5fb) |
| Pacific            | Red Hat Ceph Storage 5.0 - 5.0             | [16.2.0-117.el8cp](https://access.redhat.com/errata/RHBA-2021:3294) | N/A                                                          | [ceph-ansible-6.0.11.1-1](https://access.redhat.com/errata/RHBA-2021:3294) | N/A                             | August, 2021   | 5-14                                                         |

### A4. /etc/fstab-option

- _netdev
- x-systemd.requires=rbdmap.service
- nofail
