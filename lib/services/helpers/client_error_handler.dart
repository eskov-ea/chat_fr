import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/services/popup_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientErrorHandler {

  static void handleAppErrorException(BuildContext context, dynamic exception) {

    if (exception is! AppErrorException) {
      PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Произошла ошибка. Попробуйте еще раз.");
    } else {
      switch(exception.type) {
        case AppErrorExceptionType.network:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Соединение прервано. Произошла сетевая ошибка, причиной могут быть плохое интернет-соединение, плохое качество соединения.. Попробуйте еще раз.");
        case AppErrorExceptionType.auth:
          BlocProvider.of<ErrorHandlerBloc>(context).add(ErrorHandlerAccessDeniedEvent(error: AppErrorException(AppErrorExceptionType.auth)));
        case AppErrorExceptionType.other:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Произошла ошибка. Попробуйте еще раз.");
        case AppErrorExceptionType.sessionExpired:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Ваша сессия истекла, пожалуйста пройдите авторизацию.");
        case AppErrorExceptionType.access:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "У вас недостаточно прав пользователя для выполнения данной операции. Пожалуйста, свяжитесь с администратором.");
        case AppErrorExceptionType.parsing:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Ошибка в приложении. Мы не смогли обработать полученные с сервера данные. Пожалуйста, свяжитесь с администратором / разработчиками.");
        case AppErrorExceptionType.getData:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Произошла ошибка при получении / обработки данных. Пожалуйста, свяжитесь с администратором / разработчиками.");
        case AppErrorExceptionType.secureStorage:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Произошла ошибка при сохранении / чтении данных на / с устройства. Проверьте в настройках, что у приложении достаточно прав для доступа к памяти, попробуйте снова, при повторном возникновении ошибки - обратитесь к администратору / разработчикам.");
        case AppErrorExceptionType.socket:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Соединение прервано. Произошла сетевая ошибка, причиной могут быть плохое интернет-соединение, плохое качество соединения.. Попробуйте еще раз.");
        case AppErrorExceptionType.render:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "Произошла ошибка в приложении при рендеринге компонента. Пожалуйста, перезагрузите приложение и попробуйте снова. При возникновении повторной ошибки - свяжитесь с разработчиками.");
        case AppErrorExceptionType.requestError:
          PopupManager.showInfoPopup(context, dismissible: true, type: PopupType.error, message: "При выполнении запроса произошла ошибка. Попробуйте еще раз.");
      }
    }
  }

  static void informErrorHappened(BuildContext context, String message, {PopupType? type}) {
    PopupManager.showInfoPopup(context, dismissible: true, type: type ?? PopupType.error, message: message);
  }

  static Widget makeErrorInfoWidget(AppErrorExceptionType type, Function() callback) {
    String message = '';
    String imagePath = "assets/icons/popup-data-other-error-icon.png";
    if (type == AppErrorExceptionType.network || type == AppErrorExceptionType.socket) {
      message = "Произошла ошибка сети при загрузке данных. Возможные причины- Плохое интернет-соединения, ошибка сети. Попробуйте еще раз";
      imagePath = "assets/icons/popup-data-network-error-icon.png";
    } else if (type == AppErrorExceptionType.requestError) {
      message = "Произошла ошибка сети при загрузке данных. Отправленные на сервер данные не прошли валидацию, пожалуйста, проверьте, что все необходимые поля заполнены и попробуйте снова";
      imagePath = "assets/icons/popup-data-request-error-icon.png";
    } else if (type == AppErrorExceptionType.parsing) {
      message = "Произошла ошибка сети при обработке данных, полученных с сервера. Пожалуйста, попробуйте еще раз, при повторной ошибке обратитесь к администратору / разработчикам";
      imagePath = "assets/icons/popup-data-parsing-error-icon.png";
    } else {
      message = "Произошла непредвиденная ошибка при загрузке данных. Попробуйте еще раз или обратитесь к администратору / разработчикам";
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -100),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Image.asset(imagePath, height: 200),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -50),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: Color(0xE6FFFFFF)
              ),
              child: Text(message, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16))
            )
          ),
          Transform.translate(
            offset: Offset(0, 80),
            child: Container(
              alignment: Alignment.center,
              width: 250,
              height: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: Color(0xFF2F63E8)
              ),
              child: InkWell(
                onTap: callback,
                child: Text("Обновить", style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16))
              ),
            ),
          )
        ],
      ),
    );
  }
}