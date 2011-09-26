/****************************************************************************
**
** Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtPIM module of the Qt Toolkit.
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
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QORGANIZERJSONDBCONVERTER_H
#define QORGANIZERJSONDBCONVERTER_H

#include <QVariant>

#include "qorganizer.h"

#include <jsondb-error.h>

QTPIM_USE_NAMESPACE
Q_USE_JSONDB_NAMESPACE


struct QOrganizerJsonDbEnumConversionData
{
    int enumValue;
    const QLatin1String enumStr;
};


class QOrganizerJsonDbConverter
{
public:
    QOrganizerJsonDbConverter();

    QOrganizerManager::Error jsondbErrorToOrganizerError(JsonDbError::ErrorCode jsonErrorCode);

    bool jsonDbObjectToItem(const QVariantMap& object, QOrganizerItem* item) const;
    bool itemToJsonDbObject(const QOrganizerItem& item, QVariantMap* object) const;
    bool jsonDbObjectToCollection(const QVariantMap& object, QOrganizerCollection* collection, bool& isDefaultCollection);
    bool collectionToJsonDbObject(const QOrganizerCollection& collection, bool isDefaultCollection, QVariantMap* object) const;

private:
    void jsonDbObjectToRecurrenceRule(const QVariantMap& object, QOrganizerRecurrenceRule* rule) const;
    void recurrenceRuleToJsonDbObject(const QOrganizerRecurrenceRule& rule, QVariantMap* object) const;

    void itemReminderDetailToJsonDbObject(const QOrganizerItemReminder& itemReminder, QVariantMap& reminderObject) const;
    void jsonDbObjectToItemReminderDetailCommon(const QVariantMap& object, QOrganizerItemReminder* itemReminder) const;

    int stringToEnum(const QOrganizerJsonDbEnumConversionData* const conversionData, QString enumStr) const;
    QString enumToString(const QOrganizerJsonDbEnumConversionData* const conversionData, int enumValue) const;
};

#endif // QORGANIZERJSONDBCONVERTER_H
