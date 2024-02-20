import 'dart:io';

import 'package:chat/bloc/chats_builder_bloc/chats_builder_bloc.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/message_forwarding_util.dart';
import 'package:chat/services/helpers/message_sender_helper.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:chat/ui/widgets/avatar_widget.dart';
import 'package:chat/ui/widgets/dialog_avatar_widget.dart';
import 'package:chat/ui/widgets/dialogs/dialog_search_widget.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit_state.dart';
import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:chat/view_models/user/users_view_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ForwardAddress {
  final String name;
  final int? dialogId;
  final int? userId;

  ForwardAddress({required this.name, required this.dialogId, required this.userId});
}


class ForwardMessageAlertDialog extends StatefulWidget {
  final int userId;
  final AnimationController animationController;
  final Animation animation;
  final Function close;
  final String? forwardingText;
  final String? forwardingTextAuthor;
  final MessageAttachmentsData? forwardingFile;
  const ForwardMessageAlertDialog({
    required this.userId,
    required this.animationController,
    required this.animation,
    required this.close,
    required this.forwardingText,
    required this.forwardingTextAuthor,
    required this.forwardingFile,
    super.key
  });

  @override
  State<ForwardMessageAlertDialog> createState() => _ForwardMessageAlertDialogState();
}

class _ForwardMessageAlertDialogState extends State<ForwardMessageAlertDialog>{

  final _buttonStyle = const TextStyle(fontSize: 18, color: Colors.blueAccent);
  final _textController = TextEditingController();
  bool isInitialized = false;
  List<ForwardAddress> forwardDestination = [];
  /// мы сначала выдаем диалоги, далее юзеров. Тк у нас диалог с юзером называется именем юзера, то он совпадет с именем юзера в результате юзеров.
  /// Например диалог: Иванов Иван и юзер Иванов Иван. Чтобы избежать этого, мы заносим имена в справочник и если имя там уже есть - такоц контакт не добавляем.
  final Map<String, int> existsDialogs = {};
  List<ForwardAddress> selectedAddresses = [];

  void close() {
    setState(() {
      selectedAddresses = [];
    });
    widget.close();
  }
  String allAddressesNames() {
    String result = '';
    for (final address in selectedAddresses) {
      result += ", ${address.name}";
    }
    return result.replaceFirst(', ', '');
  }

  Future<void> forwardMessages() async {
    if (widget.forwardingText == null || widget.forwardingTextAuthor == null) {
      widget.close();
      return PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: 'Ошибка. при попытке переслать сообщение потерялся пересылаемый текст или автор сообщения. попробуйте еще раз и сообщите о возникшей проблеме разработчикам.');
    }
    PopupManager.showLoadingPopup(context);
    await Future.delayed(const Duration(milliseconds: 200));

    for (final address in selectedAddresses) {
      int? dialogId;
      if (address.dialogId != null) {
        dialogId = address.dialogId!;
      } else if (address.userId != null) {
        dialogId = findDialog(context, widget.userId, address.userId!)?.dialogId;
      }

      if (dialogId == null) {
        Navigator.of(context).pop();
        return PopupManager.showInfoPopup(context, dismissible: false, type: PopupType.error, message: 'Произошла ошибка при отправке сообщения, попробуйте еще раз');
      }

      sendForwardMessage(
          bloc: BlocProvider.of<ChatsBuilderBloc>(context),
          messageText: forwardMessage(widget.forwardingText!, widget.forwardingTextAuthor!),
          attachment: widget.forwardingFile,
          dialogId: dialogId,
          userId: widget.userId
      );
    }

    close();
    Navigator.of(context).pop();
  }


  @override
  void initState() {
    super.initState();

    final dialogsState = BlocProvider.of<DialogsViewCubit>(context).state;
    if (dialogsState is DialogsLoadedViewCubitState) {
      List<ForwardAddress> dialogs = [];
      for (final dialog in dialogsState.dialogs) {
        final name = getChatItemName(dialog, widget.userId);
        dialogs.add(ForwardAddress(name: name, dialogId: dialog.dialogId, userId: null));
        existsDialogs.addAll({name: 1});
      }
      forwardDestination.addAll(dialogs);
    }

    final usersState = BlocProvider.of<UsersViewCubit>(context).state;
    if (usersState is UsersViewCubitLoadedState) {
      List<ForwardAddress> dialogs = [];
      for (final user in usersState.users) {
        final name = "${user.lastname} ${user.firstname}";
        if (!existsDialogs.containsKey(name)) {
          dialogs.add(ForwardAddress(name: name, dialogId: null, userId: user.id));
        }
      }
      forwardDestination.addAll(dialogs);
    }
    setState(() {
      isInitialized = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.animationController.value > 0) AnimatedOpacity(
          opacity: widget.animationController.value,
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: UniqueKey(),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black54,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (MediaQuery.of(context).size.height - 150) * (1 - widget.animationController.value)),
                child: Container(
                  height: MediaQuery.of(context).size.height - 150,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )
                  ),
                  child: Column(
                    children: [
                      _controlButtonsRow(),
                      CustomSearchWidget(
                        controller: _textController,
                        searchCallback: (String) {},
                        margin: const EdgeInsets.only(top: 10, right: 0, left: 0, bottom: 20),
                      ),
                      Expanded(
                        child: !isInitialized ? Center(
                          child: CircularProgressIndicator(),
                        ) : ListView.separated(
                            separatorBuilder: (context, index) => Container(
                                padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 30) * 0.20),
                                child: const Divider(
                                    height: 5, color: Colors.black54, thickness: 1)
                            ),
                            itemCount: forwardDestination.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: (MediaQuery.of(context).size.width - 30) * 0.20,
                                        child: forwardDestination[index].userId != null ? UserAvatarWidget(userId: forwardDestination[index].userId, size: 20) : const DialogAvatar(base64String: null, radius: 20),
                                      ),
                                      Container(
                                        width: (MediaQuery.of(context).size.width - 30) * 0.65,
                                        child: Text(forwardDestination[index].name,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Container(
                                        width: (MediaQuery.of(context).size.width - 30) * 0.15,
                                        child: Checkbox(
                                          value: selectedAddresses.contains(forwardDestination[index]),
                                          onChanged: (bool? value) {
                                            if (value == true) {
                                              selectedAddresses.add(forwardDestination[index]);
                                            } else {
                                              selectedAddresses.remove(forwardDestination[index]);
                                            }
                                            setState(() {});
                                          },
                                          shape: CircleBorder(
                                              side: BorderSide(color: Colors.black54, width: 1)
                                          ),
                                          checkColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                              );
                            }
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedAddresses.isNotEmpty) Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(bottom: 20),
            decoration:  BoxDecoration(
              color: Color(0xFFF3F3F3),
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.black54),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  spreadRadius: 15
                )
              ]
            ),
            child: IntrinsicHeight(
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20, left: 15),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(allAddressesNames(), style: TextStyle(fontSize: 16, height: 1),),
                    ),
                    GestureDetector(
                      onTap: forwardMessages,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        width: 100,
                        child: Text('Переслать',
                          style: _buttonStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ]
    );
  }

  Widget _controlButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerRight,
          width: (MediaQuery.of(context).size.width - 30) / 2 + 45,
          child: Text('Отправить:',
            style: _buttonStyle,
          ),
        ),
        GestureDetector(
          onTap: close,
          child: Container(
            alignment: Alignment.centerRight,
            width: (MediaQuery.of(context).size.width - 30) / 2 -45,
            child: Text('Отменить',
              style: _buttonStyle,
            ),
          ),
        )
      ],
    );
  }
}
