### canvas 基础

#### 标签
    <canvas width="400px" height="500px">浏览器不支持</canvas>

注意:

1 ie8及其他不支持canvas的浏览器可借助插件[ExplorerCanvas](https://code.google.com/p/explorercanvas/)

2 通过style设置宽、高会导致canvas被缩放到给定的宽高
      在canvas元素的内部存在一个名为2d渲染环境（2d redering context）的对象，
      所以，通过CSS设置画布尺寸会引起奇怪的效果?
