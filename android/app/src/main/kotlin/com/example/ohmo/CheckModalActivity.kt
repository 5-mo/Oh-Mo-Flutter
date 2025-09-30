package com.example.ohmo

import android.content.Intent
import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.ohmo.model.ScheduleItem
import org.json.JSONArray
import org.json.JSONObject


class CheckModalActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ScheduleAdapter
    private val scheduleList = mutableListOf<ScheduleItem>()

    override fun onCreate(savedInstanceState: Bundle?) {
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE) // 반드시 super.onCreate 이전에 호출
        super.onCreate(savedInstanceState)
        setContentView(R.layout.check_modal_layout)

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

        loadSchedule()

        val initialScheduleState=scheduleList.map{it.copy()}

        adapter = ScheduleAdapter(scheduleList) { position, isChecked ->
            // 체크박스 상태 변경 시 데이터 업데이트
            scheduleList[position].isChecked = isChecked
            // 여기에서 변경된 상태를 저장하거나, 메인 앱으로 전달하는 로직을 추가할 수 있습니다.
        }
        recyclerView.adapter = adapter

        // 저장 버튼 클릭 리스너
        findViewById<ImageView>(R.id.close)?.setOnClickListener {
            val changedItems=mutableListOf<ScheduleItem>()
            for(i in scheduleList.indices){
                if(scheduleList[i].isChecked!=initialScheduleState[i].isChecked){
                    changedItems.add(scheduleList[i])
                }
            }

            if(changedItems.isNotEmpty()){
                val intent=Intent(this, TodoUpdateReceiver::class.java).apply{
                    action="com.example.ohmo.ACTION_UPDATE_TODOS"
                }

                val jsonArray=JSONArray()
                changedItems.forEach{item->
                    val jsonObject=org.json.JSONObject()
                    jsonObject.put("id",item.id)
                    jsonObject.put("isDone",item.isChecked)
                    jsonArray.put(jsonObject)
                }
                intent.putExtra("updated_todos",jsonArray.toString())
                sendBroadcast(intent)
            }
            finish() // 모달 닫기
        }
    }

    private fun loadSchedule(){
        scheduleList.clear()
        var prefs=getSharedPreferences("HomeWidgetPreferences",Context.MODE_PRIVATE)
        val todosJsonString=prefs.getString("today_todo",null)

        todosJsonString?.let{
            try{
                val jsonArray=JSONArray(it)
                for(i in 0 until jsonArray.length()){
                    val jsonObject=jsonArray.getJSONObject(i)
                    scheduleList.add(
                        ScheduleItem(
                            id=jsonObject.getInt("id"),
                            text=jsonObject.getString("content"),
                            isChecked=jsonObject.getBoolean("isDone")
                        )
                    )
                }
            }catch (e:Exception){
                e.printStackTrace()
            }
        }
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
