<?php

use Yii;
use yii\db\Migration;

class m260124_000003_ensure_question_subject_and_admin extends Migration
{
    public function safeUp()
    {
        $table = $this->db->schema->getTableSchema('{{%question}}', true);
        if ($table === null) {
            $this->createTable('{{%question}}', [
                'id' => $this->primaryKey(),
                'question_form' => $this->text()->notNull(),
                'subject' => $this->integer(),
                'created_at' => $this->timestamp()->defaultExpression('CURRENT_TIMESTAMP'),
            ]);
            $this->createIndex('idx_question_subject', '{{%question}}', 'subject');
        } else {
            if (!isset($table->columns['subject'])) {
                $this->addColumn('{{%question}}', 'subject', $this->integer());
                $this->createIndex('idx_question_subject', '{{%question}}', 'subject');
            }
        }

        $userTable = $this->db->schema->getTableSchema('{{%user}}', true);
        if ($userTable !== null) {
            $exists = (new \yii\db\Query())
                ->from('{{%user}}')
                ->where(['username' => 'admin'])
                ->exists($this->db);

            if (!$exists) {
                $passwordHash = Yii::$app->security->generatePasswordHash('admin');
                $authKey = Yii::$app->security->generateRandomString(32);

                $this->insert('{{%user}}', [
                    'username' => 'admin',
                    'password_hash' => $passwordHash,
                    'auth_key' => $authKey,
                    'access_token' => null,
                    'status' => 10,
                    'updated_at' => date('Y-m-d H:i:s'),
                ]);
            }
        }
    }

    public function safeDown()
    {
        $userTable = $this->db->schema->getTableSchema('{{%user}}', true);
        if ($userTable !== null) {
            $this->delete('{{%user}}', ['username' => 'admin']);
        }
    }
}
