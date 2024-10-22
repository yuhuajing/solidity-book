## 代理合约
- 代理合约底层采用dlegateCall,实现业务逻辑和slot数据存储分离。
- 由于业务和数据分离，后续可以灵活替换逻辑业务
- 由于数据按照业务代码更新相应的slot数值
    - 因此替换业务逻辑时，应该保持旧参数slot的顺序
    - 新增参数只能在末端添加
      ![](./images/proxy.png)
## 可升级合约