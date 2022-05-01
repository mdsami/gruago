import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ridy/generated/l10n.dart';
import '../graphql/generated/graphql_api.dart';
import '../main/service_item_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

import 'bloc/main_bloc.dart';

class SelectServiceView extends StatefulWidget {
  const SelectServiceView(
      {Key? key, required this.data, required this.onServiceSelect})
      : super(key: key);
  final GetFare$Query$CalculateFareDTO data;
  final ServiceSelectCallback onServiceSelect;

  @override
  _SelectServiceViewState createState() => _SelectServiceViewState();
}

class _SelectServiceViewState extends State<SelectServiceView> {
  @override
  Widget build(BuildContext context) {
    final mainBloc = (context.read<MainBloc>().state) as OrderPreview;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTabController(
                length: widget.data.services.length,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tabSection(context, widget.data.services),
                  ],
                )),
            Row(children: [
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(14)),
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: const Icon(Icons.calendar_today_outlined)),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      onPressed: mainBloc.selectedService == null
                          ? null
                          : () async {
                              int minutesFromNow = 0;
                              if (mainBloc.selectedTime != null) {
                                final now = DateTime.now();
                                minutesFromNow = mainBloc.selectedTime!
                                    .difference(now)
                                    .inMinutes;
                              }
                              widget.onServiceSelect(
                                  mainBloc.selectedService.toString(),
                                  minutesFromNow);
                            },
                      child: Text(
                        mainBloc.selectedTime == null
                            ? S.of(context).service_selection_book_now
                            : S.of(context).service_selection_book_later(
                                getHumanReadableDateTime(
                                    mainBloc.selectedTime!)),
                      ))),
            ]).pOnly(top: 10)
          ],
        ),
      ),
    );
  }

  String getHumanReadableDateTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    if (now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day) {
      return DateFormat('kk:mm').format(dateTime);
    } else {
      return DateFormat('MM-dd, kk:mm').format(dateTime);
    }
  }

  Widget _tabSection(BuildContext context,
      List<GetFare$Query$CalculateFareDTO$ServiceCategory> data) {
    return DefaultTabController(
      length: data.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
            ),
            child: Visibility(
              maintainState: true,
              visible: data.length > 1,
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: TabBar(
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.white,
                    tabs: data
                        .map((e) => Tab(
                              text: e.name,
                            ))
                        .toList()),
              ),
            ),
          ),
          SizedBox(
            height: 135,
            child: TabBarView(
              children: data.map((e) {
                return Container(child: _serviceTileList(context, e.services));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceTileList(BuildContext context,
      List<GetFare$Query$CalculateFareDTO$ServiceCategory$Service> services) {
    final mainBloc = context.read<MainBloc>();

    return ListView(
      scrollDirection: Axis.horizontal,
      children: services
          .map((e) => GestureDetector(
                onTap: () {
                  mainBloc.add(SelectService(e.id));
                },
                child: ServiceItemView(
                  service: e,
                  isSelected:
                      e.id == (mainBloc.state as OrderPreview).selectedService,
                  currency: widget.data.currency,
                ),
              ))
          .toList(),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final mainBloc = context.read<MainBloc>();
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 10)));
    if (date == null) return;
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: (mainBloc.state as OrderPreview).selectedTime != null
            ? TimeOfDay(
                hour: (mainBloc.state as OrderPreview).selectedTime!.hour,
                minute: (mainBloc.state as OrderPreview).selectedTime!.minute)
            : TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child ?? Container(),
          );
        });
    if (pickedTime == null) return;
    mainBloc.add(SelectBookingTime(DateTime(
        date.year, date.month, date.day, pickedTime.hour, pickedTime.minute)));
  }
}

typedef ServiceSelectCallback = void Function(
    String serviceId, int intervalMinutes);
