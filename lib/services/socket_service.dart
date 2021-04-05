import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig(){

    print("Intentado conexión");

    // Dart client
    this._socket = IO.io('http://192.168.18.98:3000', IO.OptionBuilder()
      .setTransports(['websocket']).enableAutoConnect().build());

    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      //socket.emit('msg', 'test');
    });
    
    this._socket.onDisconnect((_){
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    this._socket.on('nuevo-mensaje', ( payload ) {
      print( 'nuevo-mensaje: $payload');  
    });

    //socket.on('fromServer', (_) => print(_));
    //

  }
}