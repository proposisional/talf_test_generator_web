<?php

namespace app\models\database;

use yii\db\ActiveRecord;

class Test extends ActiveRecord
{
    public static function tableName()
    {
        return 'test';
    }

    public function rules()
    {
        return [
            [['date_created'], 'safe'],
            [['questions'], 'safe'],
            [['evaluation'], 'string'],
        ];
    }

    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'date_created' => 'Fecha de creación',
            'questions' => 'Preguntas',
            'evaluation' => 'Tipo de evaluación',
        ];
    }

    public function beforeSave($insert)
    {
        if (!parent::beforeSave($insert)) {
            return false;
        }

        if (is_array($this->questions)) {
            $this->questions = json_encode($this->questions, JSON_UNESCAPED_UNICODE);
        }

        if ($insert && empty($this->date_created)) {
            $this->date_created = date('Y-m-d H:i:s');
        }

        return true;
    }

    public function afterFind()
    {
        parent::afterFind();
        $raw = $this->questions;
        if (is_string($raw) && $raw !== '') {
            $decoded = json_decode($raw, true);
            if (is_string($decoded)) {
                $decoded = json_decode($decoded, true);
            }
            if (is_array($decoded)) {
                $this->questions = $decoded;
            } else {
                $this->questions = [];
            }
        } else {
            $this->questions = [];
        }
    }

    public function setQuestionsFromArray(array $questions): void
    {
        $this->questions = $questions;
    }
}

