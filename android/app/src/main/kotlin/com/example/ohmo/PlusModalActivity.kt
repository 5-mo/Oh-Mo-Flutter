package com.example.ohmo

import android.app.TimePickerDialog
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Window
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import java.util.Calendar
import java.util.Locale

class PlusModalActivity: AppCompatActivity() {

    private lateinit var editTime: EditText
    private lateinit var frameTime: FrameLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE) // 반드시 super.onCreate 이전에 호출
        super.onCreate(savedInstanceState)
        setContentView(R.layout.plus_todo_modal_layout)

        // 크기 설정
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics) // 화면 해상도 정보 가져오기
        val screenWidth = displayMetrics.widthPixels // 화면의 실제 너비 (px)

        val layoutParams = WindowManager.LayoutParams()
        layoutParams.copyFrom(window.attributes)

        layoutParams.width = (screenWidth * 0.9).toInt()
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT
        window.attributes = layoutParams

        // 저장 버튼 클릭 리스너
        findViewById<Button>(R.id.confirm_button)?.setOnClickListener {
            // 여기에서 scheduleList에 있는 변경된 데이터를 처리합니다.
            // 예: Log.d("ModalActivity", "저장된 데이터: $scheduleList")
            // 실제 앱에서는 이 데이터를 플러터 앱으로 다시 보내 위젯을 업데이트해야 합니다.
            finish() // 모달 닫기
        }

        editTime = findViewById(R.id.edit_time)
        frameTime = findViewById(R.id.time_picker_frame)
        frameTime.setOnClickListener {
            showTimePicker()
        }
        editTime.setOnClickListener {
            showTimePicker()
        }
    }

    // TimePicker Dialog를 보여주는 함수
    private fun showTimePicker() {
        val calendar = Calendar.getInstance()
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
        val currentMinute = calendar.get(Calendar.MINUTE)

        val timePickerDialog = TimePickerDialog(
            this,
            { _, hourOfDay, minute ->
                // 시간 선택 후 EditText에 설정
                val selectedTime = String.format(Locale.getDefault(), "%02d:%02d", hourOfDay, minute)
                editTime.setText(selectedTime)
            },
            currentHour,
            currentMinute,
            true // 24시간 형식 (false로 하면 AM/PM 형식)
        )
        timePickerDialog.show()
    }

}