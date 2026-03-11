import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const ONESIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID')!
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY')!

serve(async (req) => {
  try {
    // Biến payload chứa dữ liệu từ Supabase Webhook bắn sang
    const payload = await req.json()
    const record = payload.record // Biểu diễn row mới insert

    // Dữ liệu OneSignal yêu cầu
    const notificationData = {
      app_id: ONESIGNAL_APP_ID,
      
      // Nếu bạn muốn nhắm tới userId hoặc thiết bị cụ thể:
      // include_external_user_ids: [record.user_id.toString()],
      
      // Ở đây ví dụ bắn broadcast cho toàn bộ users đã subscribe
      included_segments: ['All'],
      
      contents: {
        en: record.message || 'Bạn có một thông báo mới!',
        vi: record.message || 'Bạn có một thông báo mới!',
      },
      headings: {
        en: record.title || 'EduTool',
        vi: record.title || 'EduTool',
      },
      data: {
        payload_data: record
      }
    }

    // Call REST API
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify(notificationData)
    })

    const data = await response.json()

    return new Response(
      JSON.stringify({ success: true, onesignal: data }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || String(err) }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
