import 'package:flutter/material.dart';
import 'package:catch_me/models/clientstate.dart';

class ClientstateProvider extends ChangeNotifier {
      ClientState _clientState = ClientState(timer: {
        'timer' : '',
         'Msg' : ''
      });

      Map<String,dynamic> get clientState => _clientState.toJson();

      setClientState(timer){
        _clientState = ClientState(timer: timer);
        notifyListeners();
      }

      resetClientState(){
        _clientState = ClientState(timer: {
        'timer' : '',
         'Msg' : ''
      });
        notifyListeners();
      }
}