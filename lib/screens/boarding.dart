import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lds_otp/bloc/change_pin_bloc.dart';
import 'package:lds_otp/bloc/initial_preferences_bloc.dart';
import 'package:lds_otp/screens/change_pin.dart';
import 'package:lds_otp/screens/initial_preferences.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/widgets/page_reveal.dart';
import 'package:lds_otp/widgets/pager_dragger.dart';
import 'package:lds_otp/widgets/pager_indicator.dart';
import 'package:lds_otp/widgets/pages.dart';

class BoardingScreen extends StatefulWidget {
  @override
  State createState() => _BoardingState();
}

class _BoardingState extends State<BoardingScreen> with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;

  int activeIndex = 0 ;
  SlideDirection slideDirection = SlideDirection.none;
  int nextPageIndex = 0 ;
  double slidePercent= 0.0;

  _BoardingState() {
    _initPagesStreamController();
  }

  List<PageViewModel> _buildPages(BuildContext context) {
    return [
      PageViewModel(
          color: AppColors.primaryColor,
          heroAssetPath: 'assets/images/two_factor.png',
          title: 'Autenticador Luz del Sur',
          body: Subtitle('La nueva autenticación de 2 pasos para la Plataforma Web'),
          iconData: Icons.access_time),
      PageViewModel(
        color: AppColors.accentColor,
        heroAssetPath: 'assets/images/qr_code.png',
        title:'Más fácil',
        body: Subtitle('Solo tienes que escanear el código QR que se '
            'encuentra en la Plataforma Web y listo!'
        ),
        iconData: FontAwesomeIcons.qrcode,
      ),
      PageViewModel(
          color: AppColors.primaryColor,
          heroAssetPath: 'assets/images/security.png',
          title:'Más seguro',
          body:  Subtitle('Además de tu usuario y contraseña, tendrás un código '
              'de acceso que se actualizará cada 30 s.'
          ),
          iconData: Icons.security),
      PageViewModel(
        color: AppColors.accentColor,
        heroAssetPath: 'assets/images/settings.png',
        title: 'Configuración inicial',
        body:  Center(
          child: Column(
            children: <Widget>[
              Subtitle('Establece tu PIN de acceso'),
              SizedBox(height: 20.0),
              RaisedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InitialPreferencesScreen(
                            initialPreferencesBloc: InitialPreferencesBloc()
                        )
                  ));
                },
                color: AppColors.primaryColor,
                textColor: AppColors.textColor,
                icon: Icon(Icons.check_circle),
                label: Text("Empecemos!"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
              ),
            ],
          ),
        ),
        iconData: Icons.settings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var pages = _buildPages(context);
    return Scaffold(
      body: Stack(
        children: [
          Page(
            viewModel: pages[activeIndex],
            percentVisible: 1.0 ,
          ),
          PageReveal(
            revealPercent: slidePercent,
            child: new Page(
              viewModel: pages[nextPageIndex],
              percentVisible: slidePercent ,
            ),
          ),
          PagerIndicator(
            viewModel: new PagerIndicatorViewModel(
              pages,
              activeIndex,
              slideDirection,
              slidePercent,
            ),
          ),
          PageDragger(
            canDragLeftToRight: activeIndex > 0 ,
            canDragRightToLeft: activeIndex < pages.length - 1 ,
            slideUpdateStream: this.slideUpdateStream,
          )
        ],
      ),
    );
  }

  void _initPagesStreamController(){
    slideUpdateStream = new StreamController<SlideUpdate>();

    slideUpdateStream.stream.listen((SlideUpdate event){
      setState(() {
        if( event.updateType == UpdateType.dragging ){
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if( slideDirection == SlideDirection.leftToRight ){
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.rightToLeft){
            nextPageIndex = activeIndex + 1;
          } else{
            nextPageIndex = activeIndex;
          }
        } else if( event.updateType == UpdateType.doneDragging){
          if(slidePercent > 0.5){

            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );

          } else{
            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        }
        else if( event.updateType == UpdateType.animating ){
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        }

        else if (event.updateType == UpdateType.doneAnimating ){
          activeIndex = nextPageIndex;

          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        }
      });
    });
  }
}


class Subtitle extends StatelessWidget {
  final String data;
  final Color color;
  Subtitle(this.data, { this.color });

  @override
  Widget build(BuildContext context) {
    return Text(data,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: 18.0,
      ),
    );
  }
}