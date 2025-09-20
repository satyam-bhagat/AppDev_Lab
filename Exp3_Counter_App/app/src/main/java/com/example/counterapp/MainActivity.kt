package com.example.counterapp

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : AppCompatActivity() {


    private lateinit var counter_txt: TextView
    private lateinit var button_click_increase: Button
    private lateinit var button_click_decrease: Button
    private lateinit var button_click_reset: Button

    private var counter = 0




    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        counter_txt=findViewById(R.id.textView)
        button_click_increase=findViewById(R.id.button)

        button_click_decrease=findViewById(R.id.button2)

        button_click_reset=findViewById(R.id.button3)




        button_click_increase.setOnClickListener {
            counter++
            counter_txt.text=counter.toString()
        }

        button_click_decrease.setOnClickListener {
            counter--
            counter_txt.text=counter.toString()
        }


        button_click_reset.setOnClickListener {
            counter=0
            counter_txt.text=counter.toString()
        }







        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
    }
}