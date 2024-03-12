import 'dart:async';
import 'package:chat/services/sip_connection_service/sip_repository.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/global.dart';
import 'package:chat/theme.dart';
import 'package:chat/ui/navigation/main_navigation.dart';
import 'package:chat/ui/pages/new_group_options_page.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



PreferredSizeWidget CustomAppBar(context)  {

    return PreferredSize(
      preferredSize: Size(getWidthMaxWidthGuard(context), 56),
      child: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const WebsocketStatusWidget(),
        leadingWidth: 54,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 3.0,),
            child: _SipServicePageIcon(),
          ),
          Padding(
            padding: EdgeInsets.only(right: 3.0,),
            child: _CreateNewDialogIcon(),
          ),
        ],
      ),
    );
}

class WebsocketStatusWidget extends StatefulWidget {
  const WebsocketStatusWidget({super.key});

  @override
  State<WebsocketStatusWidget> createState() => _WebsocketStatusWidgetState();
}

class _WebsocketStatusWidgetState extends State<WebsocketStatusWidget> {

  PusherChannelsClientLifeCycleState state = PusherChannelsClientLifeCycleState.inactive;
  late final StreamSubscription<PusherChannelsClientLifeCycleState> _websocketStateSubscription;
  final _websocketRepo = WebsocketRepository.instance;
  final textStyle = const TextStyle(color: LightColors.mainText, fontSize: 20, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    setState(() {
      state = _websocketRepo.currentState;
    });
    _websocketStateSubscription = _websocketRepo.state.listen((event) {
      setState(() {
        state = event;
      });
    });
  }

  @override
  void dispose() {
    _websocketStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('curstate::::::  $state');
    if (state == PusherChannelsClientLifeCycleState.establishedConnection) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('MCFEF',
            style: textStyle,
            softWrap: true,
          )
      );
    } else if (state == PusherChannelsClientLifeCycleState.inactive) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Не подключен',
            style: textStyle,
            softWrap: true,
          )
      );
    } else if (state == PusherChannelsClientLifeCycleState.pendingConnection) {
      return Row(
        children: [
          Text(
            'Подключение...',
            style: textStyle,
            softWrap: true,
          ),
          const SizedBox(width: 20),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: LightColors.mainText,
              strokeWidth: 2.0,
            ),
          )
        ],
      );
    } else  {
      return Row(
        children: [
          Text('Ошибка подключения',
            style: textStyle,
            softWrap: true,
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
              final dialogs = await DBProvider.db.getDialogs();
              _websocketRepo.connect(dialogs);
            },
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.refresh, size: 30, color:  Colors.black87),
            ),
          )
        ],
      );
    }
  }
}

class _SipServicePageIcon extends StatefulWidget {
  const _SipServicePageIcon({super.key});

  @override
  State<_SipServicePageIcon> createState() => _SipServicePageIconState();
}

class _SipServicePageIconState extends State<_SipServicePageIcon> {

  late final StreamSubscription<SipConnectionState> _sipConnectionState;
  SipConnectionState _connectionState = SipConnectionState(status: ConnectionStatus.none, message: null);
  Color _color = Colors.grey;
  Color _fillColor = Colors.grey.shade100;

  void _onSipConnectionStateChange(SipConnectionState state) {
    if ( state.status == ConnectionStatus.connected ) {
      _color = Colors.green.shade700;
      _fillColor = Colors.greenAccent.shade100;
    } else if (state.status == ConnectionStatus.progress ) {
      _color = Colors.blue.shade700;
      _fillColor = Colors.blueAccent.shade100;
    } else if (state.status == ConnectionStatus.failed ) {
      _color = Colors.red.shade700;
      _fillColor = Colors.redAccent.shade100;
    } else {
      _color = Colors.grey;
      _fillColor = Colors.grey.shade100;
    }
    setState(() {
      _connectionState = state;
    });
  }

  @override
  void initState() {
    setState(() {
      _connectionState = SipRepository.instance.state;
      _onSipConnectionStateChange(SipRepository.instance.state);
    });
    _sipConnectionState = SipRepository.instance.stream.listen(_onSipConnectionStateChange);
    super.initState();
  }

  @override
  void dispose() {
    _sipConnectionState.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(MainNavigationRouteNames.sipConnectionScreen);
      },
      child: Container(
        alignment: Alignment.center,
        width: 60,
        height: 25,
        child: Container(
          width: 60,
          height: 25,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            color: _fillColor,
            border: Border.all(color: _color, width: 3.0)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                width: 30,
                child: Text('SIP',
                  style: TextStyle(color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 15,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



class _CreateNewDialogIcon extends StatelessWidget {
  const _CreateNewDialogIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var _bloc = BlocProvider.of<UsersViewCubit>(context);
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.launch, color: AppColors.secondary, size: 25),
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => CreateNewDialogPage(bloc: _bloc),
        );
      },
    );
  }
}
