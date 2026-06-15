<?php

namespace app\models;

use yii\base\Model;

class TestForm extends Model
{
    public $title;
    public $date;
    public $description;
    public $image;
    public $questions = [Question];

    public function rules()
    {
        return [
            [['title', 'choices', 'correct_choices'], 'required'],
            [['title', 'description', 'date', 'image'], 'string', 'max' => 255],
            ['choices', 'each', 'rule' => ['Question']]
        ];
    }
    public function attributeLabels()
    {
        return [
            'title' => 'Título del examen',
            'description' => 'Descripción del examen',
            'image' => 'Imagen de la pregunta',
            'choices' => 'Posibles respuestas',
            'correct_choices' => 'Respuestas correctas',
        ];
    }

}
