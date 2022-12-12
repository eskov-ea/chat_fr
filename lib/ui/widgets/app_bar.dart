import 'package:chat/ui/pages/new_message_page.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/websocket/websocket_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';


PreferredSizeWidget CustomAppBar(context)  {
    return AppBar(
      iconTheme: Theme.of(context).iconTheme,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: BlocBuilder<WebsocketViewCubit, WebsocketViewCubitState>(
        builder: (context, state) {
          if (state == WebsocketViewCubitState.connected) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('MCFEF',
                style: TextStyle(color: LightColors.mainText, fontSize: 22, fontWeight: FontWeight.w700),
              )
            );
          } else {
            return Row(
              children: const [
                Text(
                  'Подключение...',
                  style: TextStyle(color: LightColors.mainText, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 20,),
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
      // leading: Align(
      //   alignment: Alignment.centerRight,
      //   child: IconBackground(
      //     icon: Icons.search,
      //     onTap: () async {
      //     },
      //   ),
      // ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 24.0,),
          child: _OptionsIcon(),
        ),
      ],
    );
}


class _OptionsIcon extends StatelessWidget {
  const _OptionsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var _bloc = BlocProvider.of<UsersViewCubit>(context);
    return IconButton(
      icon: const Icon(Icons.launch, color: AppColors.secondary, size: 30,),
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