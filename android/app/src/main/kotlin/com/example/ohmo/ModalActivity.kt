package com.example.ohmo

import android.graphics.Typeface
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import android.view.Window
import android.view.WindowManager
import android.widget.Button
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.ohmo.R
import com.example.ohmo.model.ScheduleItem

class ModalActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ScheduleAdapter
    private val scheduleList = mutableListOf<ScheduleItem>()

    override fun onCreate(savedInstanceState: Bundle?) {
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE) // 반드시 super.onCreate 이전에 호출
        super.onCreate(savedInstanceState)
        setContentView(R.layout.modal_layout)

        // 크기 설정
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics) // 화면 해상도 정보 가져오기
        val screenWidth = displayMetrics.widthPixels // 화면의 실제 너비 (px)

        val layoutParams = WindowManager.LayoutParams()
        layoutParams.copyFrom(window.attributes)

        layoutParams.width = (screenWidth * 0.8).toInt()
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT
        window.attributes = layoutParams

        val textView = findViewById<TextView>(R.id.to_do)
        val typeface = Typeface.createFromAsset(assets, "fonts/RubikSprayPaint-Regular.ttf")
        textView.typeface = typeface

        // RecyclerView 초기화
        recyclerView = findViewById(R.id.schedule_recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(this)

        // 샘플 데이터 로드 (실제 앱에서는 여기서 위젯의 데이터를 가져와야 합니다!)
        loadSampleScheduleData()

        adapter = ScheduleAdapter(scheduleList) { position, isChecked ->
            // 체크박스 상태 변경 시 데이터 업데이트
            scheduleList[position].isChecked = isChecked
            // 여기에서 변경된 상태를 저장하거나, 메인 앱으로 전달하는 로직을 추가할 수 있습니다.
        }
        recyclerView.adapter = adapter

        // 저장 버튼 클릭 리스너
        findViewById<ImageView>(R.id.close)?.setOnClickListener {
            // 여기에서 scheduleList에 있는 변경된 데이터를 처리합니다.
            // 예: Log.d("ModalActivity", "저장된 데이터: $scheduleList")
            // 실제 앱에서는 이 데이터를 플러터 앱으로 다시 보내 위젯을 업데이트해야 합니다.
            finish() // 모달 닫기
        }
    }

    // 샘플 데이터 로드 메서드 (실제 앱에서는 이 부분을 수정하여 위젯 데이터와 연동)
    private fun loadSampleScheduleData() {
        // 이 데이터는 위젯의 RemoteViewsFactory에서 사용하는 데이터와 동일하거나,
        // 메인 앱에서 관리하는 실제 일정 데이터가 되어야 합니다.
        scheduleList.add(ScheduleItem("C++ 과제 제출", false))
        scheduleList.add(ScheduleItem("주교재 도서관에서 빌리기", true))
        scheduleList.add(ScheduleItem("알고리즘 스터디 준비", false))
        scheduleList.add(ScheduleItem("플러터 위젯 개발 완료", true))
        scheduleList.add(ScheduleItem("앱 아이디어 구체화", false))
    }

    // RecyclerView 어댑터 클래스
    class ScheduleAdapter(
        private val items: List<ScheduleItem>,
        private val onCheckboxClicked: (position: Int, isChecked: Boolean) -> Unit
    ) : RecyclerView.Adapter<ScheduleAdapter.ScheduleViewHolder>() {

        class ScheduleViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val checkBox: CheckBox = view.findViewById(R.id.schedule_checkbox)
            val textView: TextView = view.findViewById(R.id.schedule_text)
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ScheduleViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_schedule_checkbox, parent, false)
            return ScheduleViewHolder(view)
        }

        override fun onBindViewHolder(holder: ScheduleViewHolder, position: Int) {
            val currentItem = items[position]
            holder.textView.text = currentItem.text
            holder.checkBox.isChecked = currentItem.isChecked

            // 체크박스 클릭 리스너 설정
            holder.checkBox.setOnCheckedChangeListener { _, isChecked ->
                onCheckboxClicked(position, isChecked)
            }
        }

        override fun getItemCount(): Int = items.size
    }
}