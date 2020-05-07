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
  const HomeView({
    Key key,
    this.menuCallback,
    this.menuAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: IconButton(
          onPressed: menuCallback,
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
            child: Text("Content"),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                menuCallback();
              },
              child: Container(
                width: 150,
                color: Colors.red.withOpacity(.6),
              ),
            ),
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

typedef SlidableMenuBuilder = Widget Function(Function, Animation<double>);

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
  void handleMenu() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    } else if (_controller.status == AnimationStatus.forward) {
      _controller.reverse();
    } else if (_controller.status == AnimationStatus.reverse) {
      _controller.forward();
    }
  }

  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<Offset> _slideAnimation;
  Animation<double> _menuAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));

    _scaleAnimation = Tween<double>(begin: 1, end: .8).animate(
      CurvedAnimation(
        curve: Curves.easeInOutSine,
        parent: _controller,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(.5, 0),
    ).animate(
      _controller,
    );

    _menuAnimation = Tween<double>(begin: 1, end: 0).animate(
      _controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.menu,
        SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            child: widget.builder(handleMenu, _menuAnimation),
            scale: _scaleAnimation,
          ),
        ),
      ],
    );
  }
}
