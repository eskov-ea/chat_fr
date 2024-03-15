import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UsersViewCubit>();
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: TextField(
        controller: _controller,
        focusNode: _searchFocus,
        style: const TextStyle(fontSize: 18),
        onChanged: (string){
         cubit.searchContact(string);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          labelText: 'Поиск',
          filled: false,
          fillColor: Theme.of(context).backgroundColor,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: (){
              _controller.clear();
              _searchFocus.unfocus();
              cubit.resetSearchQuery();

            },
          )
        ),
      ),
    );
  }
}