package com.example.ohmo.factory

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.example.ohmo.R
import org.json.JSONArray

class ToDoWidgetRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    private val mWidgetItems: MutableList<String> = ArrayList()

    override fun onCreate() {
        // 데이터 초기화: 위젯이 처음 생성될 때 호출됩니다.
        // 실제 앱에서는 여기서 데이터베이스나 네트워크에서 데이터를 가져올 수 있습니다.
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData(){
        mWidgetItems.clear()

        val prefs=context.getSharedPreferences("HomeWidgetPreferences",Context.MODE_PRIVATE)

        val todosJsonString=prefs.getString("today_todo",null)

        todosJsonString?.let{
            try{
                val jsonArray=JSONArray(it)
                for(i in 0 until jsonArray.length()){
                    val jsonObject=jsonArray.getJSONObject(i)
                    val content=jsonObject.getString("content")
                    mWidgetItems.add(content)
                }
            }catch (e:Exception){
                e.printStackTrace()
            }
        }
    }

    override fun onDestroy() {
        // 리소스 해제: 위젯이 제거될 때 호출됩니다.
        mWidgetItems.clear()
    }

    override fun getCount(): Int {
        // 리스트 아이템의 총 개수를 반환합니다.
        return mWidgetItems.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        // 특정 위치(position)의 아이템에 대한 RemoteViews를 반환합니다.
        val rv = RemoteViews(context.packageName, R.layout.widget_list_item)
        rv.setTextViewText(R.id.list_item_text, mWidgetItems[position])

        // (선택 사항) 리스트 아이템 클릭 이벤트 처리
        // val fillInIntent = Intent()
        // rv.setOnClickFillInIntent(R.id.list_item_text, fillInIntent)

        return rv
    }

    override fun getLoadingView(): RemoteViews? {
        // 데이터 로딩 중 표시할 뷰를 반환합니다. (선택 사항, null 반환 시 기본 로딩 뷰)
        return null
    }

    override fun getViewTypeCount(): Int {
        // 리스트 아이템 뷰 타입의 총 개수를 반환합니다. (모든 아이템이 동일한 레이아웃이면 1)
        return 1
    }

    override fun getItemId(position: Int): Long {
        // 특정 위치의 아이템 ID를 반환합니다.
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        // 아이템 ID가 안정적인지 여부를 반환합니다. (데이터 변경 시 ID가 유지되면 true)
        return true
    }
}