import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:ban_names_2/models/band.dart';
import 'package:ban_names_2/services/socket_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  // List<Band> bands = [
  //   Band(id: '1', name: 'Metallica', votes: 5),
  //   Band(id: '2', name: 'Metallica2', votes: 6),
  //   Band(id: '3', name: 'Metallica3', votes: 7),
  //   Band(id: '4', name: 'Metallica4', votes: 8),
  // ];

  @override
  void initState() { 
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands( dynamic payload ){    
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList( );
    setState(() {});
    print(bands);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87 ),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.Online ? 
              Icon(Icons.check_circle, color: Colors.blue[300]) :
              Icon(Icons.offline_bolt, color: Colors.red)
            )
              //
              
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) => _bandTile( bands[index] )
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible (
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only( left: 20.0 ),
        color: Colors.red[300],
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white ),)
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle( fontSize: 18 ),),
        onTap: () => socketService.socket.emit('vote-band', { "id": band.id })
      ),
    );
  }

  addNewBand() {

    final textController = new TextEditingController();

    if( Platform.isAndroid ){
      // Android
      showDialog(
        context: context, 
        builder: ( _ ) => AlertDialog(
          title: Text('New Band Name'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList( textController.text )
            )
          ],
        ),
      );
    }else{

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
          title: Text(' New Band Name:'),
          content: CupertinoTextField(controller: textController,),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList( textController.text ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
      );
    }
  }

  void addBandToList( String name ) {
    


    if ( name.length > 1 ) {
      // Podemos agregar
      //this.bands.add( new Band(id: DateTime.now().toString(), name: name, votes: 0 ));
    
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {
        "name": name,
      });
    
    }else{
      print(name.length);
    }
    

    Navigator.pop(context);
  }

  // Mostrar Gráfica
  Widget _showGraph(){
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap[band.name] = band.votes.toDouble();
    });

    return PieChart(dataMap: dataMap);
  }

}
