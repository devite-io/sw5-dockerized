<?php
return [
    'db' => [
        'username' => 'root',
        'password' => '%db.password%',
        'dbname' => 'shopware',
        'host' => 'database',
        'port' => '3306',
    ],
    'model' => [
        'redisHost' => 'valkey',
        'redisPort' => 6379,
        'redisDbIndex' => 0,
        'redisAuth' => '%valkey.password%',
        'cacheProvider' => 'redis'
    ],
    'cache' => [
        'backend' => 'redis',
        'backendOptions' => [
            'servers' => [
                [
                    'host' => 'valkey',
                    'port' => 6379,
                    'dbindex' => 0,
                    'redisAuth' => '%valkey.password%',
                ],
            ],
        ],
        'httpcache' => [
            'enabled' => true,
        ],
    ],
    'es' => [
        'prefix' => 'sw',
        'enabled' => true,
        'write_backlog' => false,
        'wait_for_status' => 'green',
        'dynamic_mapping_enabled' => true,
        'batchsize' => 500,
        'index_settings' => [
            'number_of_shards' => 1,
            'number_of_replicas' => 0,
            'max_result_window' => 10000,
            'mapping' => [
                'total_fields' => [
                    'limit' => null,
                ],
            ],
        ],
        'backend' => [
            'prefix' => 'sw_backend_index_',
            'batchsize' => 500,
            'write_backlog' => false,
            'enabled' => true,
            'index_settings' => [
                'number_of_shards' => 1,
                'number_of_replicas' => 0,
                'max_result_window' => 10000,
                'mapping' => [
                    'total_fields' => [
                        'limit' => null,
                    ],
                ],
            ],
        ],
        'client' => [
            'hosts' => [
                'elasticsearch:9200',
            ],
        ],
        'logger' => [
            /* @see https://github.com/Seldaek/monolog/blob/main/src/Monolog/Logger.php */
            'level' => 400 /* = Monolog\Logger::ERROR */,
        ]
    ],
    'trustedProxies' => [
        '127.0.0.1',
    ],
];
