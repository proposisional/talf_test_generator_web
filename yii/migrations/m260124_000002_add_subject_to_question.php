<?php

use yii\db\Migration;

class m260124_000002_add_subject_to_question extends Migration
{
    public function safeUp()
    {
        $this->addColumn('{{%question}}', 'subject', $this->integer());
        $this->createIndex('idx_question_subject', '{{%question}}', 'subject');
    }

    public function safeDown()
    {
        $this->dropIndex('idx_question_subject', '{{%question}}');
        $this->dropColumn('{{%question}}', 'subject');
    }
}
