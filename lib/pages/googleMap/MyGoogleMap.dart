import 'dart:async'; // 导入异步操作包
import 'dart:convert'; // 导入编码解码包
import 'dart:typed_data'; // 导入字节数据包

import 'package:flutter/material.dart'; // 导入Flutter UI包
import 'package:flutter/services.dart'; // 导入Flutter服务包
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 导入Google Maps包
import 'package:geolocator/geolocator.dart'; // 导入Geolocator包
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理包

class MyGoogleMap extends StatefulWidget { // 创建一个有状态的组件MyGoogleMap
  const MyGoogleMap({super.key}); // 构造函数

  @override
  State<MyGoogleMap> createState() => _MyGoogleMapState(); // 创建MyGoogleMap状态
}

class _MyGoogleMapState extends State<MyGoogleMap> { // 定义MyGoogleMap的状态类
  final Completer<GoogleMapController> _controller = Completer(); // 完成GoogleMapController的操作
  GoogleMapController? controllerGoogleMap; // 定义GoogleMapController
  String? mapStyle; // 地图样式字符串
  static const CameraPosition _initialPosition = CameraPosition( // 定义初始相机位置
    target: LatLng(35.6378, 140.2038),
    zoom: 17,
  );

  @override
  void initState() { // 初始化状态
    super.initState();
    requestLocationPermission(); // 请求定位权限
    loadMapStyle(); // 加载地图样式
  }

  void loadMapStyle() async { // 加载地图样式的方法
    mapStyle = await getJsonFileFromThemes("themes/night_style.json"); // 获取地图样式JSON
    setState(() {}); // 更新状态以重新构建UI
  }

  Future<void> requestLocationPermission() async { // 请求定位权限的方法
    var status = await Permission.location.request(); // 请求定位权限
    if (status.isGranted) { // 如果权限被授予
      print("定位权限已授予");
    } else if (status.isDenied) { // 如果权限被拒绝
      print("定位权限被拒绝");
    } else if (status.isPermanentlyDenied) { // 如果权限被永久拒绝
      print("定位权限被永久拒绝，请在设置中开启");
    }
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async { // 异步获取JSON文件的方法
    ByteData byteData = await rootBundle.load(mapStylePath); // 加载字节数据
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes); // 转换为字节列表
    return utf8.decode(list); // 解码字节列表为字符串
  }

  Future<Position> _determinePosition() async { // 获取当前位置的方法
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置服务未启用，返回默认位置
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 位置权限被拒绝，返回默认位置
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 位置权限被永久拒绝，返回默认位置
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 获取当前位置
    return await Geolocator.getCurrentPosition();
  }

  void _goToCurrentLocation() async { // 移动到当前位置的方法
    Position position = await _determinePosition();
    controllerGoogleMap?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // 构建UI
    return Scaffold(
      body: SafeArea( // 使用安全区域布局
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition, // 设置初始相机位置
                onMapCreated: (GoogleMapController controller) { // 地图创建时的回调
                  controllerGoogleMap = controller; // 保存控制器
                  _controller.complete(controllerGoogleMap); // 完成控制器
                },
                myLocationEnabled: true, // 启用我的位置
                myLocationButtonEnabled: false, // 禁用默认我的位置按钮
                mapType: MapType.normal, // 设置地图类型为普通
                style: mapStyle, // 设置地图样式
              ),
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton(
                  onPressed: _goToCurrentLocation, // 移动到当前位置
                  child: Icon(Icons.my_location),
                ),
              ),
            ],
          )),
    );
  }
}
