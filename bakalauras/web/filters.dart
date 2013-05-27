import 'dart:html';
import 'package:web_ui/watcher.dart' as watchers;

import 'tests/tests.dart';

var selected = new List(10);
var activeTab = new List(10);
var active = 0;

void main() {
  
  initMenu();
  
  query('#kalmanTest').onClick.listen((MouseEvent event) {
    event.preventDefault();
    num time = double.parse(query('#kalmanTime').value);
    num pNoise = double.parse(query('#kalmanPNoise').value);
    num mNoise = double.parse(query('#kalmanMNoise').value);
    num Ex1 = double.parse(query('#kalmanEx1').value);
    num Ez1 = double.parse(query('#kalmanEz1').value);
    num Ex2 = double.parse(query('#kalmanEx2').value);
    num Ez2 = double.parse(query('#kalmanEz2').value);
    new KalmanTest(time, mNoise, pNoise, Ex1, Ez1, Ex2, Ez2);
  });
  

  query('#particlesTest').onClick.listen((MouseEvent event) {
    event.preventDefault();
    num time = double.parse(query('#particlesTime').value);
    num pNoise = double.parse(query('#particlesPNoise').value);
    num mNoise = double.parse(query('#particlesMNoise').value);
    num count1 = double.parse(query('#particlesCount1').value);
    num count2 = double.parse(query('#particlesCount1').value);
    new ParticlesTest(time, mNoise, pNoise, count1, count2);
  });
  
  
  //new SimpleTest();
  query('#simpleTest').onClick.listen((MouseEvent event) {
    event.preventDefault();
    num pNoise = double.parse(query('#pNoise').value);
    num mNoise = double.parse(query('#mNoise').value);
    num pCount = int.parse(query('#pCount').value);
    new SimpleTest(mNoise, pNoise, pCount);
  });
  
  query('#moveTest').onClick.listen((MouseEvent event) {
    event.preventDefault();
    num pNoise = double.parse(query('#pNoise1').value);
    num mNoise = double.parse(query('#mNoise1').value);
    num pCount = int.parse(query('#pCount1').value);
    new MoveTest(mNoise, pNoise, pCount); 
  }); 
  
  new WalkTest();
  
}

void initMenu() {

  for (var i = 0; i < selected.length; i++) {
    selected[i] = 'hide';  
    activeTab[i] = '';
  }
  
  void select(int newActive) {
    selected[active] = 'hide';
    activeTab[active] = '';
    active = newActive;
    selected[active] = 'show';
    activeTab[active] = 'active';
    watchers.dispatch();
  };
  
  queryAll('.tab').forEach((var e) {
    e.classes.add('hide');
    e.onClick.listen((var event) {
      select(int.parse(e.attributes['x-tab']));
    });
  });
  
  select(0); 
  
}
