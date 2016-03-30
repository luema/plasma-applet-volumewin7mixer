import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "shared.js" as Shared

Item {
    id: agendaView

    //anchors.margins: units.largeSpacing
    property int spacing: units.largeSpacing
    property alias agendaListView: agenda

    property int showNextNumDays: 14
    property bool clipPastEvents: false
    property bool clipPastEventsToday: false
    property bool cfg_clock_24h: false
    property bool cfg_agenda_weather_show_icon: false
    property int cfg_agenda_weather_icon_height: 24
    property bool cfg_agenda_weather_show_text: false

    signal newEventFormOpened(variant agendaItem, variant newEventCalendarId)
    signal submitNewEventForm(variant calendarId, variant date, string text)

    ListModel {
        id: agendaModel
    }

    width: 400
    height: 400

    // Testing with qmlview
    Rectangle {
        visible: typeof popup === 'undefined'
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }
    
    ListView {
        id: agenda
        model: agendaModel
        anchors.fill: parent
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds

        // Don't bother garbage collecting
        // GC or Reloading the weather images is very slow.
        cacheBuffer: 10000000 

        delegate: RowLayout {
            Layout.fillWidth: true
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            LinkRect {
                Layout.alignment: Qt.AlignTop

                Column {
                    id: itemWeatherColumn
                    width: 50
                    Layout.alignment: Qt.AlignTop

                    FontIcon {
                        visible: showWeather && cfg_agenda_weather_show_icon
                        source: weatherIcon
                        height: cfg_agenda_weather_icon_height
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    Text {
                        id: itemWeatherText
                        visible: showWeather && cfg_agenda_weather_show_text
                        text: weatherText
                        color: PlasmaCore.ColorScope.textColor
                        opacity: 0.75
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        id: itemWeatherTemps
                        visible: showWeather
                        text: tempHigh + '° | ' + tempLow + '°'
                        color: PlasmaCore.ColorScope.textColor
                        opacity: 0.75
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // PlasmaCore.ToolTipArea {
                //     anchors.fill: parent
                //     mainText: weatherDescription
                //     subText: {
                //         var lines = [];
                //         lines.push(tempHigh + '° | ' + tempLow + '°');
                //         lines.push('<b>Morning:</b> ' + tempMorn + '°');
                //         lines.push('<b>Day:</b> ' + tempDay + '°');
                //         lines.push('<b>Evening:</b> ' + tempEve + '°');
                //         lines.push('<b>Night:</b> ' + tempNight + '°');
                //         return lines.join('<br>');
                //     }
                //     icon: weatherIcon
                // }

                onClicked: {
                    console.log('agendaItem.date.clicked', date)
                    if (true) {
                        // cfg_agenda_weather_clicked == "browser_viewcityforecast"
                        if (config.weather_city_id) {
                            Shared.openOpenWeatherMapCityUrl(config.weather_city_id);
                        }
                    }
                }
            }

            LinkRect {
                Layout.alignment: Qt.AlignTop

                Column {
                    id: itemDateColumn
                    width: 50

                    Text {
                        id: itemDate
                        text: Qt.formatDateTime(date, "MMM d")
                        color: PlasmaCore.ColorScope.textColor
                        opacity: 0.75
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        horizontalAlignment: Text.AlignRight

                        // MouseArea {
                        //     anchors.fill: itemDateColumn
                        //     onClicked: {
                        //         newEventInput.forceActiveFocus()
                        //     }
                        // }
                    }

                    Text {
                        id: itemDay
                        text: Qt.formatDateTime(date, "ddd")
                        color: PlasmaCore.ColorScope.textColor
                        opacity: 0.5
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        horizontalAlignment: Text.AlignRight
                    }
                }

                onClicked: {
                    console.log('agendaItem.date.clicked', date)
                    if (false) {
                        // cfg_agenda_date_clicked == "browser_newevent"
                        Shared.openGoogleCalendarNewEventUrl(date);
                    } else if (true) {
                        // cfg_agenda_date_clicked == "agenda_newevent"
                        newEventForm.visible = !newEventForm.visible
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                spacing: 0
                Item {
                    Layout.fillWidth: true
                }


                ColumnLayout {
                    id: newEventForm
                    visible: false
                    onVisibleChanged: {
                        if (visible) {
                            newEventText.forceActiveFocus()
                            newEventFormOpened(model, newEventCalendarId)
                        }
                    }
                    PlasmaComponents.ComboBox {
                        id: newEventCalendarId
                        Layout.fillWidth: true
                        model: ['asdf']
                    }

                    RowLayout {
                        PlasmaComponents.TextField {
                            id: newEventText
                            Layout.fillWidth: true
                            placeholderText: "Eg: 9am-5pm Work"
                            onAccepted: {
                                var calendarId = newEventCalendarId.model[newEventCalendarId.currentIndex]
                                submitNewEventForm(calendarId, date, text)
                                text = ''
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 10
                    }
                }

                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Repeater {
                        model: events

                        // delegate: Rectangle {
                        delegate: LinkRect {
                            width: undefined
                            Layout.fillWidth: true
                            height: eventColumn.height

                            RowLayout {
                                Rectangle {
                                    width: 2
                                    height: eventColumn.height
                                    color: model.backgroundColor
                                }

                                ColumnLayout {
                                    id: eventColumn
                                    // Layout.fillWidth: true

                                    Text {
                                        id: eventSummary
                                        text: summary
                                        color: PlasmaCore.ColorScope.textColor
                                    }

                                    Text {
                                        id: eventDateTime
                                        text: {
                                            if (start.date) {
                                                return "All Day"
                                            } else {
                                                var s = formatEventTime(start.dateTime);
                                                if (start.dateTime.valueOf() != end.dateTime.valueOf()) {
                                                    s += " - ";
                                                    if (!(start.dateTime.getFullYear() == end.dateTime.getFullYear() && start.dateTime.getMonth() == end.dateTime.getMonth() && start.dateTime.getDate() == end.dateTime.getDate())) {
                                                        s += Qt.formatDateTime(end.dateTime, "MMM d") + ", ";
                                                    }
                                                    s += formatEventTime(end.dateTime);
                                                }
                                                return s;
                                            }
                                        }
                                        color: PlasmaCore.ColorScope.textColor
                                        opacity: 0.75

                                        function formatEventTime(dateTime) {
                                            var timeFormat = "h"
                                            if (dateTime.getMinutes() != 0) {
                                                timeFormat += ":mm"
                                            }
                                            if (!cfg_clock_24h) {
                                                timeFormat += " AP"
                                            }
                                            return Qt.formatDateTime(dateTime, timeFormat)
                                        }
                                    }
                                }
                            }

                            onClicked: {
                                console.log('agendaItem.event.clicked', start.date)
                                if (true) {
                                    // cfg_agenda_event_clicked == "browser_viewevent"
                                    Qt.openUrlExternally(htmlLink)
                                }
                            }
                        }
                    }
                }

            }
        }
    }

    function scrollToTop() {
        agendaListView.positionViewAtBeginning()
    }

    function scrollToDate(date) {
        for (var i = 0; i < agendaModel.count; i++) {
            var agendaItem = agendaModel.get(i);
            if (date.getFullYear() == agendaItem.date.getFullYear() && date.getMonth() == agendaItem.date.getMonth() && date.getDate() == agendaItem.date.getDate()) {
                agendaListView.positionViewAtIndex(i, ListView.Beginning);
                return;
            } else if (date < agendaItem.date) { // assume agendaItem.date is aligned to midnight
                // If the date is smaller than the current agendaItem.date, scroll to the previous agendaItem.
                if (i > 0) {
                    agendaListView.positionViewAtIndex(i-1, ListView.Beginning);
                } else {
                    agendaListView.positionViewAtBeginning()
                }
                return;
            }
        }
        // If the date is greater than any item in the agenda, scroll to the bottom.
        agendaListView.positionViewAtEnd()
    }

    function buildAgendaItem(dateTime) {
        return {
            date: dateTime,
            events: [],
            showWeather: false,
            tempLow: 0,
            tempHigh: 0,
            weatherIcon: "",
            weatherText: "",
            weatherDescription: "",
            weather: {
                temp: {
                    morn: 0,
                    day: 0,
                    eve: 0,
                    night: 0,
                },
                pressure: 0,
                humidity: 0,
                speed: 0,
                clouds: 93,
                rain: 0,
                snow: 2.69,
            },
        };
    }

    function parseGCalEvents(data) {
        agendaModel.clear();

        if (!(data && data.items))
            return;

        // var eventItemList = [];
        // var timeZoneOffset = new Date().getTimezoneOffset()/60;
        // timeZoneOffset = 'Z' + (timeZoneOffset > 0 ? '-' : '+') + timeZoneOffset + '00';
        // console.log(timeZoneOffset);
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];

            if (eventItem.start.date) {
                eventItem.start.dateTime = new Date(eventItem.start.date + ' 00:00:00');
            } else {
                eventItem.start.dateTime = new Date(eventItem.start.dateTime);
            }
            // console.log(eventItem.start.dateTime, eventItem.summary);

            if (eventItem.end.date) {
                eventItem.end.dateTime = new Date(eventItem.end.date + ' 00:00:00');
            } else {
                eventItem.end.dateTime = new Date(eventItem.end.dateTime);
            }

            // eventItemList.push(eventItem);
        }
        data.items.sort(function(a,b) { return a.start.dateTime - b.start.dateTime; });

        // for (var i = 0; i < data.items.length; i++) {
        //     var eventItem = data.items[i];
        //     console.log(eventItem.start.dateTime, eventItem.summary);
        // }

        var agendaItemList = [];
        var agendaItem;
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];
            // console.log(agendaItem && agendaItem.date.getDate(), eventItem.start.dateTime.getDate());
            var isSameDay = agendaItem && agendaItem.date.getDate() == eventItem.start.dateTime.getDate();
            if (!agendaItem || !isSameDay) {
                if (agendaItem) {
                    agendaItemList.push(agendaItem);
                }
                agendaItem = buildAgendaItem(eventItem.start.dateTime);
            }

            agendaItem.events.push(eventItem);
        }
        if (agendaItem) {
            agendaItemList.push(agendaItem);
        }

        if (showNextNumDays > 0) {
            var today = new Date();
            var end = new Date().setDate(today.getDate() + showNextNumDays);
            for (var day = new Date(today); day <= end; day.setDate(day.getDate() + 1)) {
                // console.log(day);

                // Check if agenedaItem with this date already exists.
                var index = -1;
                for (var i = 0; i < agendaItemList.length; i++) {
                    var agendaItem = agendaItemList[i];
                    if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() == agendaItem.date.getDate()) {
                        index = i;
                        break;
                    }
                }
                if (index >= 0) {
                    // It does, so skip.
                    continue;
                }

                // It doesn't, so we need to insert an item.
                var newAgendaItem = buildAgendaItem(new Date(day));

                // Insert before the agendaItem with a higher date.
                for (var i = 0; i < agendaItemList.length; i++) {
                    var agendaItem = agendaItemList[i];
                    if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() < agendaItem.date.getDate()) {
                        index = i;
                        break;
                    }
                }

                if (index >= 0) {
                    // Insert at index
                    agendaItemList.splice(i, 0, newAgendaItem);
                } else {
                    // Append
                    agendaItemList.push(newAgendaItem);
                }
                // console.log('uneventfulDay:', day);
            }
        }
        
        if (clipPastEvents) {
            // Remove calendar events before today.
            var minDate = today;
            if (!clipPastEventsToday) {
                minDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
            }
            for (var i = 0; i < agendaItemList.length; i++) {
                var agendaItem = agendaItemList[i];
                if (agendaItem.date < minDate) {
                    // console.log('removed agendaItem:', agendaItem.date)
                    agendaItemList.splice(i, 1);
                    i--;
                }
            }
        }

        for (var i = 0; i < agendaItemList.length; i++) {
            agendaModel.append(agendaItemList[i]);
        }
    }

    function parseWeatherForecast(data) {
        if (!(data && data.list))
            return;

        // http://openweathermap.org/weather-conditions
        var weatherIconMap = {
            '01d': 'weather-clear',
            '02d': 'weather-few-clouds',
            '03d': 'weather-clouds',
            '04d': 'weather-overcast',
            '09d': 'weather-showers-scattered',
            '10d': 'weather-showers',
            '11d': 'weather-storm',
            '13d': 'weather-snow',
            '50d': 'weather-fog',
            '01n': 'weather-clear-night',
            '02n': 'weather-few-clouds',
            '03n': 'weather-clouds',
            '04n': 'weather-overcast',
            '09n': 'weather-showers-scattered',
            '10n': 'weather-showers',
            '11n': 'weather-storm',
            '13n': 'weather-snow',
            '50n': 'weather-fog',
        };

        for (var j = 0; j < data.list.length; j++) {
            var forecastItem = data.list[j];
            var day = new Date(forecastItem.dt * 1000);

            for (var i = 0; i < agendaModel.count; i++) {
                var agendaItem = agendaModel.get(i);
                if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() == agendaItem.date.getDate()) {
                    // console.log(day);
                    agendaItem.tempLow = Math.floor(forecastItem.temp.min);
                    agendaItem.tempHigh = Math.ceil(forecastItem.temp.max);
                    agendaModel.setProperty(i, 'tempLow', Math.floor(forecastItem.temp.min));
                    agendaModel.setProperty(i, 'tempHigh', Math.ceil(forecastItem.temp.max));
                    var weatherIcon = weatherIconMap[forecastItem.weather[0].icon] || 'weather-severe-alert';
                    agendaModel.setProperty(i, 'weatherIcon', weatherIcon);
                    agendaModel.setProperty(i, 'weatherText', forecastItem.weather[0].main);
                    agendaModel.setProperty(i, 'weatherDescription', forecastItem.weather[0].description);
                    // agendaModel.setProperty(i, 'tempMorn', Math.round(forecastItem.temp.morn));
                    // agendaModel.setProperty(i, 'tempDay', Math.round(forecastItem.temp.day));
                    // agendaModel.setProperty(i, 'tempEve', Math.round(forecastItem.temp.eve));
                    // agendaModel.setProperty(i, 'tempNight', Math.round(forecastItem.temp.night));
                    agendaModel.setProperty(i, 'showWeather', true);
                    
                    break;
                }
            }
        }
    }

    Component.onCompleted: {
        parseGCalEvents({ "items": [], });
        parseWeatherForecast({ "list": [], });

        if (typeof root === 'undefined') {
            clipPastEvents = false
            var debugEventData = {
                "items": [
                    {
                        "kind": "calendar#event",
                        "etag": "\"2561779720126000\"",
                        "id": "a1a1a1a1a1a1a1a1a1a1a1a1a1_20160325",
                        "status": "confirmed",
                        "htmlLink": "https://www.google.com/calendar/event?eid=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa&ctz=Etc/UTC",
                        "created": "2008-03-24T22:34:26.000Z",
                        "updated": "2010-08-04T02:44:20.063Z",
                        "summary": "Dude's Birthday",
                        "start": {
                            "date": "2016-03-25"
                        },
                        "end": {
                            "date": "2016-03-26"
                        },
                        "recurringEventId": "a1a1a1a1a1a1a1a1a1a1a1a1a1",
                        "originalStartTime": {
                            "date": "2016-03-25"
                        },
                        "transparency": "transparent",
                        "iCalUID": "a1a1a1a1a1a1a1a1a1a1a1a1a1@google.com",
                        "sequence": 0,
                        "reminders": {
                            "useDefault": false
                        },

                        // Optional
                        "backgroundColor": "#9a9cff" // We apply the calendar.backgroundColor
                    },
                ] 
            };
            debugEventData.items.push(debugEventData.items[0]);
            parseGCalEvents(debugEventData);

            var debugWeatherData = {
                "city": {
                    "id": 1,
                    "name": "Area 51",
                    "coord": {
                        "lon": 0.249672,
                        "lat": 0.550098
                    },
                    "country": "CA",
                    "population": 0
                },
                "cod": "200",
                "message": 0.0275,
                "cnt": 7,
                "list": [
                    {
                        "dt": 1459270800,
                        "temp": {
                            "day": 5.3,
                            "min": -6.14,
                            "max": 5.43,
                            "night": -6.14,
                            "eve": 1.01,
                            "morn": 5.3
                        },
                        "pressure": 1006.93,
                        "humidity": 49,
                        "weather": [
                            {
                            "id": 800,
                            "main": "Clear",
                            "description": "clear sky",
                            "icon": "01d"
                            }
                        ],
                        "speed": 6.82,
                        "deg": 327,
                        "clouds": 0
                    },
                ],
            };
            parseWeatherForecast(debugWeatherData);

        }
    }
}
