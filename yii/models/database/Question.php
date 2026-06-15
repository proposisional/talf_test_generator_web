<?php

namespace app\models\database;

use yii\db\ActiveRecord;

class Question extends ActiveRecord
{
    public $title;
    public $stem;
    public $image;
    public $choices = [];
    public $correct_choices = [];
    public $subject = null;
    public $is_multiple;

    public static function tableName()
    {
        return 'question';
    }

    public function rules()
    {
        return [
            [['stem', 'choices', 'correct_choices'], 'required'],
            [['title', 'stem', 'image'], 'string'],
            [['choices', 'correct_choices'], 'safe'],
            [['is_multiple'], 'boolean'],
            [['subject'], 'integer'],
        ];
    }

    public function beforeSave($insert)
    {
        if (parent::beforeSave($insert)) {
            $subjectValue = $this->subject;
            if ($subjectValue === null) {
                $subjectValue = $this->getAttribute('subject');
            }
            $subjectValue = ($subjectValue === '' || $subjectValue === false) ? null : $subjectValue;
            $this->setAttribute('subject', $subjectValue === null ? null : (int) $subjectValue);

            $this->question_form = json_encode([
                'title' => $this->title,
                'stem' => $this->stem,
                'image' => $this->image,
                'choices' => $this->choices,
                'correct_choices' => $this->correct_choices,
                'subject' => $subjectValue === null ? null : (int) $subjectValue,
            ], JSON_UNESCAPED_UNICODE);
            return true;
        }
        return false;
    }

    public function afterFind()
    {
        parent::afterFind();
        $data = json_decode($this->question_form, true);
        if (is_array($data)) {
            $this->title = $data['title'] ?? '';
            $this->stem = $data['stem'] ?? '';
            $this->image = $data['image'] ?? '';
            $this->choices = $data['choices'] ?? [];
            $this->correct_choices = $data['correct_choices'] ?? [];
            $subjectAttr = $this->getAttribute('subject');
            $this->subject = $subjectAttr !== null ? (int) $subjectAttr : ($data['subject'] ?? null);
            $this->is_multiple = count($this->correct_choices) > 1;
        }
    }
}
