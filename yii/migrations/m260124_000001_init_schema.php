<?php

use yii\db\Migration;

class m260124_000001_init_schema extends Migration
{
    public function safeUp()
    {
        $this->createTable('{{%question}}', [
            'id' => $this->primaryKey(),
            'question_form' => $this->text()->notNull(),
            'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->createTable('{{%test}}', [
            'id' => $this->primaryKey(),
            'date_created' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            'questions' => $this->text(),
            'evaluation' => $this->string(64),
        ]);

        $this->createTable('{{%user}}', [
            'id' => $this->primaryKey(),
            'username' => $this->string(64)->notNull(),
            'password_hash' => $this->string(255)->notNull(),
            'auth_key' => $this->string(64)->notNull(),
            'access_token' => $this->string(128),
            'status' => $this->integer()->notNull()->defaultValue(10),
            'updated_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);
        $this->createIndex('idx_user_username_unique', '{{%user}}', 'username', true);

        $this->createTable('{{%answer}}', [
            'id' => $this->primaryKey(),
            'test_id' => $this->integer()->notNull(),
            'user_id' => $this->integer(),
            'score' => $this->decimal(6, 2),
            'answers_json' => $this->text(),
            'date_created' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
        ]);

        $this->createIndex('idx_answer_test_id', '{{%answer}}', 'test_id');
        $this->createIndex('idx_answer_user_id', '{{%answer}}', 'user_id');

        $this->addForeignKey(
            'fk_answer_test',
            '{{%answer}}',
            'test_id',
            '{{%test}}',
            'id',
            'CASCADE',
            'CASCADE'
        );

        $this->addForeignKey(
            'fk_answer_user',
            '{{%answer}}',
            'user_id',
            '{{%user}}',
            'id',
            'SET NULL',
            'CASCADE'
        );
    }

    public function safeDown()
    {
        $this->dropForeignKey('fk_answer_user', '{{%answer}}');
        $this->dropForeignKey('fk_answer_test', '{{%answer}}');

        $this->dropTable('{{%answer}}');
        $this->dropTable('{{%user}}');
        $this->dropTable('{{%test}}');
        $this->dropTable('{{%question}}');
    }
}
