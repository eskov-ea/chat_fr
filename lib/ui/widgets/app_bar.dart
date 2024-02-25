import 'package:chat/services/global.dart';
import 'package:chat/ui/pages/new_group_options_page.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/websocket/websocket_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';


PreferredSizeWidget CustomAppBar(context)  {

    const textStyle = TextStyle(color: LightColors.mainText, fontSize: 20, fontWeight: FontWeight.w500);
    return PreferredSize(
      preferredSize: Size(getWidthMaxWidthGuard(context), 56),
      child: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.white,
        elevation: 0,

        title: BlocBuilder<WebsocketViewCubit, WebsocketViewCubitState>(
          builder: (context, state) {
            if (state == WebsocketViewCubitState.connected) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('MCFEF',
                  style: textStyle,
                )
              );
            } else if (state == WebsocketViewCubitState.unconnected) {
              return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Не подключен',
                    style: textStyle,
                  )
              );
            } else {
              return const Row(
                children: [
                  Text(
                    'Подключение...',
                    style: textStyle,
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: LightColors.mainText,
                      strokeWidth: 2.0,
                    ),
                  )
                ],
              );
            }
          }),
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
