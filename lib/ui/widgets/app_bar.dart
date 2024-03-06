import 'dart:async';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/global.dart';
import 'package:chat/theme.dart';
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
            padding: EdgeInsets.only(right: 24.0,),
            child: _OptionsIcon(),
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
          )
      );
    } else if (state == PusherChannelsClientLifeCycleState.inactive) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Не подключен',
            style: textStyle,
          )
      );
    } else if (state == PusherChannelsClientLifeCycleState.pendingConnection) {
      return Row(
        children: [
          Text(
            'Подключение...',
            style: textStyle,
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
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () async {
                final dialogs = await DBProvider.db.getDialogs();
                _websocketRepo.connect(dialogs);
              },
            ),
          )
        ],
      );
    }
  }
}



class _OptionsIcon extends StatelessWidget {
  const _OptionsIcon({Key? key}) : super(key: key);

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
          builder: (context) => NewMessagePage(bloc: _bloc),
        );
      },
    );
  }
}
