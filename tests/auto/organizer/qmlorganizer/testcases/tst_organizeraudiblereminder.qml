/****************************************************************************
**
** Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this
** file. Please review the following information to ensure the GNU Lesser
** General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file. Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtTest 1.0
import QtOrganizer 5.0

Rectangle {
    id: test;

    QOrganizerTestUtility {
        id: utility
    }

    TestCase {
        name: "test_audibleReminder"

        function test_audibleReminder_data() {
            return [
                   { tag: "  no properties",
                     code: "import QtOrganizer 5.0;"
                        + "AudibleReminder {"
                        + "}"
                    },
                    { tag: "  1 properties",
                      code: "import QtOrganizer 5.0;"
                        + "AudibleReminder {"
                        + "    repetitionCount: 3; }"
                    },
                    { tag: "  2 properties",
                      code: "import QtOrganizer 5.0;"
                        + "AudibleReminder {"
                        + "    repetitionCount: 3; "
                        + "    repetitionDelay: 30;}"
                    },
                    { tag: "  3 properties",
                      code: "import QtOrganizer 5.0;"
                        + "AudibleReminder {"
                        + "    repetitionCount: 0; "
                        + "    secondsBeforeStart: 100;}"
                    },
                    { tag: "  4 properties",
                      code: "import QtOrganizer 5.0;"
                         + "AudibleReminder {"
                         + "    repetitionCount: 3; "
                         + "    repetitionDelay: 30; "
                         + "    secondsBeforeStart: 40; "
                         + "    dataUrl: \"www.nokia.com\"  }"
                    },
            ]
        }

        function test_audibleReminder(data) {

            var list = utility.getManagerList();
            if (list.length < 0) {
                console.log("No manager to test");
                return;
            }
            //Test all manager backends
            for (var i = 0; i < list.length; i ++) {
                var managerName = list[i];
                var debugFlag = 1;
                console.log("AudibleReminder test start! :" + managerName);
                var model = Qt.createQmlObject(
                      "import QtOrganizer 5.0;"
                    + "OrganizerModel {"
                    + "   manager: \"qtorganizer:" + managerName + ":id=qml\";"
                    + "   startPeriod:'2009-01-01';"
                    + "   endPeriod:'2012-12-31';"
                    + "   autoUpdate:true; }"
                    , test);

                var event = Qt.createQmlObject(
                          "import QtOrganizer 5.0;"
                        + "Event { "
                        + "   id:event;"
                        + "   displayLabel: \"organizer qml reminder test event\"; "
                        + "   description: \"This is a new reminder event!!!\"; "
                        + "   startDateTime: '2010-12-12'; "
                        + "   endDateTime: '2010-12-13'; }"
                        , test);

                var audibleReminderDetail = Qt.createQmlObject(data.code , event);
                utility.init(model);
                utility.waitModelChange();
                utility.empty_calendar();
                //------Create and save the detail test------//
                utility.debug("Create and save the detail test", debugFlag);
                audibleReminderDetail.dataUrl = "http://www.test0.com";
                event.addDetail(audibleReminderDetail);
                if (managerName == "jsondb") {
                    // custom fields allowed in JsonDb for audible reminder
                    // simple test here, since already fully tested in C++
                    var extendedDetail = Qt.createQmlObject(
                            "import QtOrganizer 5.0;"
                            + "ExtendedDetail {"
                            + "  name: \"reminder\";"
                            + "  data: \{"
                            + "    Qt: \"Everywhere\";"
                            + "    Url: \"http://www.qt-project.org/\";"
                            + "  }"
                            + "}"
                            , test);
                    event.addDetail(extendedDetail);
                }
                model.saveItem(event);
                //Let's wait for the model to be up-to-date
                utility.waitModelChange(1);
                compare(model.itemCount, 1);

                var fetchlist = model.items;
                var savedEvent = fetchlist[0];
                verify(savedEvent != undefined);
                verify(savedEvent.detail(Detail.AudibleReminder) != undefined);
                utility.compareReminderDetails(audibleReminderDetail, savedEvent.detail(Detail.AudibleReminder));

                //------update the detail test------//
                var savedEventDetail = savedEvent.detail(Detail.AudibleReminder);
                savedEventDetail.dataUrl = "http://www.test222.com";
                savedEventDetail.secondsBeforeStart = 300;
                savedEventDetail.repetitionCount = 0;

                audibleReminderDetail.dataUrl = "http://www.test222.com";
                audibleReminderDetail.secondsBeforeStart = 300;
                audibleReminderDetail.repetitionCount = 0;

                savedEvent.setDetail(savedEventDetail);

                model.saveItem(savedEvent);
                utility.organizerChangedSpy.wait();
                //no new event created
                compare(model.itemCount, 1)
                fetchlist = model.items;
                var updatedEvent = fetchlist[0];
                var updatedEventDetail = updatedEvent.detail(Detail.AudibleReminder);
                verify(updatedEvent != undefined);
                utility.compareReminderDetails(audibleReminderDetail, updatedEventDetail);

                //------remove the detail test------//
                utility.debug("Remove the detail test", debugFlag);
                var removeEventDetail = updatedEvent.detail(Detail.AudibleReminder);
                updatedEvent.removeDetail(removeEventDetail);
                model.saveItem(updatedEvent);
                utility.organizerChangedSpy.wait();
                //no new event created
                compare(model.itemCount, 1)
                fetchlist = model.items;
                var detailRemovedEvent = fetchlist[0];
                var detailRemovedEventDetailList = detailRemovedEvent.details(Detail.AudibleReminder);
                if (detailRemovedEventDetailList.length > 0)
                    utility.outputDetail(detailRemovedEvent.detail(Detail.AudibleReminder));
                verify(detailRemovedEventDetailList.length == 0)
                verify(removeEventDetail != undefined)
                utility.empty_calendar();
                utility.organizerChangedSpy.clear();
                utility.organizerChangedSpy.destroy();
                model.destroy();
                event.destroy();
                audibleReminderDetail.destroy();
            }
        }
    }
}
