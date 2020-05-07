import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.system,
      home: SlidableMenu(
        builder: (menuCallback, menuAnimation) => HomeView(
          menuCallback: menuCallback,
          menuAnimation: menuAnimation,
        ),
        menu: Menu(),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final Function menuCallback;
  final Animation<double> menuAnimation;
  const HomeView({Key key, this.menuCallback, this.menuAnimation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: IconButton(
          onPressed: () => menuCallback(
            Gesture.DONT_CARE,
          ),
          icon: AnimatedIcon(
            progress: menuAnimation,
            icon: AnimatedIcons.arrow_menu,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: FlatButton(
              child: Text("Content"),
              onPressed: () {
                print("A");
              },
            ),
          ),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == 0) {
                return;
              }
              menuCallback(
                details.primaryVelocity > 0 ? Gesture.RIGHT : Gesture.LEFT,
              );
            },
          )
        ],
      ),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}

typedef SlidableMenuBuilder = Widget Function(MenuCallback, Animation<double>);

typedef MenuCallback = void Function(Gesture);

enum Gesture { DONT_CARE, LEFT, RIGHT }

class SlidableMenu extends StatefulWidget {
  final Widget menu;
  final SlidableMenuBuilder builder;

  const SlidableMenu({
    Key key,
    @required this.menu,
    @required this.builder,
  }) : super(key: key);

  @override
  _SlidableMenuState createState() => _SlidableMenuState();
}

class _SlidableMenuState extends State<SlidableMenu>
    with SingleTickerProviderStateMixin {
  void handleMenu(Gesture gesture) {
    if (_controller.status == AnimationStatus.completed &&
        (gesture == Gesture.DONT_CARE || gesture == Gesture.LEFT)) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.dismissed &&
        (gesture == Gesture.DONT_CARE || gesture == Gesture.RIGHT)) {
      _controller.forward();
    } else if (_controller.status == AnimationStatus.forward &&
        (gesture == Gesture.DONT_CARE || gesture == Gesture.RIGHT)) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.reverse &&
        (gesture == Gesture.DONT_CARE || gesture == Gesture.LEFT)) {
      _controller.forward();
    }
  }

  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<Offset> _slideAnimation;
  Animation<double> _menuAnimation;
  Animation<double> _rectAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: .8).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _controller,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(.5, 0),
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _controller,
      ),
    );

    _menuAnimation = Tween<double>(begin: 1, end: 0).animate(
      _controller,
    );

    _rectAnimation = Tween<double>(begin: 0, end: 20).animate(
      _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.menu,
        SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 5,
              child: RectTransition(
                rect: _rectAnimation,
                child: widget.builder(
                  handleMenu,
                  _menuAnimation,
                ),
              ),
            ),
            scale: _scaleAnimation,
          ),
        ),
      ],
    );
  }
}

class RectTransition extends AnimatedWidget {
  final Animation<double> rect;
  final Widget child;

  RectTransition({
    @required this.rect,
    @required this.child,
  }) : super(listenable: rect);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: child,
      borderRadius: BorderRadius.circular(
        rect.value,
      ),
    );
  }
}
