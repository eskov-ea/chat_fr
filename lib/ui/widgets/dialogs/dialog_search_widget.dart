import 'package:chat/theme.dart';
import 'package:chat/view_models/dialogs_page/dialogs_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogSearch extends StatefulWidget {
  const DialogSearch({
    required this.controller,
    super.key});

  final TextEditingController controller;

  @override
  State<DialogSearch> createState() => _DialogSearchState();
}

class _DialogSearchState extends State<DialogSearch> {
  final FocusNode _searchFocus = FocusNode();


  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<DialogsViewCubit>(context);
    return Container(
      height: 35,
      padding: const EdgeInsets.only(left: 15),
      margin: const EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.search),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _searchFocus,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 18),
              onChanged: (string){
                cubit.search(string);
              },
              onTapOutside: (event) {
                if (_searchFocus.hasFocus) {
                  _searchFocus.unfocus();
                }
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  label: const Text('Поиск'),
                  hintText: 'Поиск',
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: AppColors.backgroundLight)
                  ),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: AppColors.backgroundLight)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: AppColors.backgroundLight)
                  ),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.clear),
                    onPressed: (){
                      widget.controller.clear();
                      _searchFocus.unfocus();

                    },
                  )
              ),
            ),
          )
        ],
      )
    );
  }
}
