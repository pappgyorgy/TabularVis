abstract class ComponentWithDrawerInside {
  bool _visibility = true;

  bool get drawerVisibility => this._visibility;

  set drawerVisibility(bool value) => this._visibility = value;

  void toggle(){
    this._visibility = !this._visibility;
  }
  void open(){
    this._visibility = true;
  }
  void close(){
    this._visibility = false;
  }
}