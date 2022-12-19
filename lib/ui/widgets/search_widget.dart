import 'package:chat/view_models/user/users_view_cubit.dart';
import 'package:flutter/material.dart';


class SearchWidget extends StatefulWidget {
  const SearchWidget({required this.cubit ,Key? key}) : super(key: key);

  final UsersViewCubit cubit;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    // final cubit = context.read<UsersViewCubit>();
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: TextField(
        controller: _controller,
        focusNode: _searchFocus,
        style: const TextStyle(fontSize: 18),
        onChanged: (string){
          widget.cubit.searchContact(string);
          print("SEARCHWIGET   ${widget.cubit.state.users}");
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
              widget.cubit.resetSearchQuery();

            },
          )
        ),
      ),
    );
  }
}