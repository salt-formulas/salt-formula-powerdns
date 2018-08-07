# -*- coding: utf-8 -*-
'''
PowerDNS MySQL interections
==========================

:depends:   - MySQLdb Python module
:configuration: See :py:mod:`salt.modules.mysql` for setup instructions.

The mysql_query module is used to execute queries on MySQL databases.
Its output may be stored in a file or in a grain.

Sometimes you would need to store information about PowerDNS supermasters
in tables to work with.
Here is an example of making sure rows with specific data exist:

  .. code-block:: yaml

    use_supermaster_127.0.0.1:
      powerdns_mysql.row_present:
        - table: supermasters
        - where_sql: ip="127.0.0.1"
        - database: powerdns
        - data:
            ip: 127.0.0.1
            nameserver: ns.localhost.local
            account: master

Comprehensive example could be found in file:
powerdns/server/backends/mysql.sls
'''

import sys
import salt.utils
import salt.ext.six as six


def __virtual__():
    '''
    Only load if the mysql module is available in __salt__
    '''
    return 'mysql.query' in __salt__


def _get_mysql_error():
    '''
    Look in module context for a MySQL error. Eventually we should make a less
    ugly way of doing this.
    '''
    return sys.modules[
        __salt__['test.ping'].__module__
    ].__context__.pop('mysql.error', None)


def row_present(name,
        database,
        table,
        data,
        where_sql,
        update=False,
        **connection_args):
    '''
    Checks to make sure the given row exists. If row exists and update is True
    then row will be updated with data. Otherwise it will leave existing
    row unmodified and check it against data. If the existing data
    doesn't match data check the state will fail.  If the row doesn't
    exist then it will insert data into the table. If more than one
    row matches, then the state will fail.

    name
        Used only as an ID

    database
        The name of the database to execute the query on

    table
        The table name to check the data

    data
        The dictionary of key/value pairs to check against if
        row exists, insert into the table if it doesn't

    where_sql
        The SQL to select the row to check

    update
        True will replace the existing row with data
        When False and the row exists and data does not equal
        the row data then the state will fail

    connection_args
        MySQL connection arguments to connect to MySQL server with
    '''

    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Database {0} is already present'.format(database)}

    # check if database exists
    if not __salt__['mysql.db_exists'](database, **connection_args):
        err = _get_mysql_error()
        if err is not None:
            ret['comment'] = err
            ret['result'] = False
            return ret

        ret['result'] = None
        ret['comment'] = ('Database {0} is not present'
                ).format(name)
        return ret

    try:
        query = "SELECT * FROM `" + table + "` WHERE " + where_sql
        select_result = __salt__['mysql.query'](database, query, **connection_args)

        if select_result['rows returned'] > 1:
            ret['result'] = False
            ret['comment'] = 'More than one row matched the specified query'
        elif select_result['rows returned'] == 1:
            # create ordered dict of values returned by mysql.query function
            old_data = salt.utils.odict.OrderedDict()
            for num in xrange(0, len(select_result['columns'])):
                old_data[select_result['columns'][num]] = select_result['results'][0][num]

            for key, value in six.iteritems(data):
                if key in old_data and old_data[key] != value:
                    if update:
                        if __opts__['test']:
                            ret['result'] = True
                            ret['comment'] = "Row will be update in " + table
                        else:
                            columns = []
                            for key, value in six.iteritems(data):
                                columns.append('`' + key + '`="' + value + '"')

                            query = "UPDATE `" + table + "` SET "
                            query += ",".join(columns)
                            query += " WHERE "
                            query += where_sql
                            update_result = __salt__['mysql.query'](database, query, **connection_args)

                            if update_result['rows affected'] == 1:
                                ret['result'] = True
                                ret['comment'] = "Row updated"
                                ret['changes']['old'] = old_data
                                ret['changes']['new'] = data
                            else:
                                ret['result'] = None
                                ret['comment'] = "Row update failed"
                    else:
                        ret['result'] = False
                        ret['comment'] = "Existing data does" + \
                                             "not match desired state"
                        break

            if ret['result'] is None:
                ret['result'] = True
                ret['comment'] = "Row exists"
        else:
            if __opts__['test']:
                ret['result'] = True
                ret['changes']['new'] = data
                ret['comment'] = "Row will be inserted into " + table
            else:
                columns = []
                values = []
                for key, value in six.iteritems(data):
                    values.append('"' + value + '"')
                    columns.append("`" + key + "`")

                query = "INSERT INTO `" + table + "` ("
                query += ",".join(columns)
                query += ") VALUES ("
                query += ",".join(values)
                query += ")"
                insert_result = __salt__['mysql.query'](database, query, **connection_args)

                if insert_result['rows affected'] == 1:
                    ret['result'] = True
                    ret['changes']['new'] = data
                    ret['comment'] = 'Inserted row'
                else:
                    ret['result'] = False
                    ret['comment'] = "Unable to insert data"

    except Exception as e:
        ret['result'] = False
        ret['comment'] = str(e)

    return ret
