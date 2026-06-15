<?php

namespace app\models\database;

use yii\db\ActiveRecord;

class Answer extends ActiveRecord
{
    public $answers = [];

    public static function tableName()
    {
        return 'answer';
    }

    public function rules()
    {
        return [
            [['test_id'], 'required'],
            [['test_id', 'user_id'], 'integer'],
            [['score'], 'number'],
            [['answers_json'], 'string'],
            [['date_created'], 'safe'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'test_id' => 'Test',
            'user_id' => 'Usuario',
            'score' => 'Nota',
            'answers_json' => 'Respuestas',
            'date_created' => 'Fecha',
        ];
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }
        if ($insert && empty($this->date_created)) {
            $this->date_created = date('Y-m-d H:i:s');
        }
        if (is_array($this->answers)) {
            $this->answers_json = json_encode($this->answers, JSON_UNESCAPED_UNICODE);
        }
        return true;
    }

    public function afterFind()
    {
        parent::afterFind();
        $raw = $this->answers_json;
        $decoded = [];
        if (is_string($raw) && $raw !== '') {
            $decoded = json_decode($raw, true);
            if (is_string($decoded)) {
                $decoded = json_decode($decoded, true);
            }
        }
        $this->answers = is_array($decoded) ? $decoded : [];
    }

    public function setAnswers(array $answers): void
    {
        $this->answers = $answers;
    }

    public function getTest()
    {
        return $this->hasOne(Test::class, ['id' => 'test_id']);
    }

    public function getUser()
    {
        return $this->hasOne(User::class, ['id' => 'user_id']);
    }
}
