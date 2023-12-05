import 'package:chat/bloc/calls_bloc/calls_bloc.dart';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/global.dart';
import '../../theme.dart';

class CallButton extends StatelessWidget {
  const CallButton({
    required this.partnerId,
    super.key
  });

  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallsBloc, CallState>(
      builder: (context, state) {

        final bool active = state is ConnectedCallServiceState || state is EndedCallState || state is EndCallWithNoLogState;

        return active ? IconButton(
          icon: const Icon(
            CupertinoIcons.phone,
            color: AppColors.secondary ,
            size: 30
          ),
          onPressed: () {
            callNumber(context, partnerId.toString());
          },
        ) : const Icon(
          CupertinoIcons.phone,
          color: AppColors.textFaded,
          size: 30
        );
      }
    );
  }
}
