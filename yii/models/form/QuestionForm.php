<?php

namespace app\models;

use yii\base\Model;

class QuestionForm extends Model
{
    public $title;
    public $stem;
    public $image;
    public $choices = [];
    public $correct_choices = [];

    public function rules()
    {
        return [
            [['title', 'choices', 'correct_choices'], 'required'],
            [['title', 'stem', 'image'], 'string', 'max' => 255],
            ['choices', 'each', 'rule' => ['string']],
            ['correct_choices', 'each', 'rule' => ['in', 'range' => array_keys($this->choices)]]
        ];
    }

    public function attributeLabels()
    {
        return [
            'title' => 'Título de la pregunta',
            'stem' => 'Descripción de la pregunta',
            'image' => 'Imagen de la pregunta',
            'choices' => 'Posibles preguntas',
            'correct_choices' => 'Respuestas correctas',
        ];
    }

}
