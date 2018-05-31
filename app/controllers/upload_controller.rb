class UploadController < ApplicationController

  before_action :authenticate_user
  skip_before_action :verify_authenticity_token

  def upload_image
    file = params[:img]
    if !file.content_type.match(/^image\/(gif|png|jpg|jpeg){1}$/)
      success = false
      msg = "#{file.original_filename}: 只支持上传JPG、JPEG、PNG、GIF格式图片"
    elsif file.size > 1 * 1024 * 1024
      success = false
      msg = "#{file.original_filename}: 图片过大，请上传小于1M的图片"
    else
      success = true
      msg = "上传成功！"
    end
    render text: save_file(file)
  end

  def upload_base64_image
    base64 = params[:base64Data]
    render text: save_base64_file(base64)
  end

  def upload_avatar
    base64 = params[:avatar]
    avatar_url = save_base64_file(base64)
    file = "#{Rails.root}/config/blogine.yml"
    config = YAML.load_file(file)
    config['production']['blogine']['avatar'] = avatar_url
    File.open(file, 'w') do |h|
      h.write config.to_yaml
    end
    Settings.reload! # reload config without restart app
    render json: {status: 1, message: avatar_url}
  rescue => x
    render json: {status: 0, message: '更新头像失败，请稍后重试！'}
  end

  private

  def save_base64_file(base_64_encoded_data)
    extname = 'png'
    filename = '粘贴图片'
    uri = File.join('uploads', 'images', "#{DateTime.now.strftime('%Y/%m%d/%H%M%S')}_#{SecureRandom.hex(4)}.#{extname}")
    save_path = Rails.root.join('public', uri)
    file_dir = File.dirname(save_path)

    FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
    File.open save_path, 'wb' do |f|
      f.write(Base64.decode64(base_64_encoded_data.split(",")[1]))
    end

    prot = Rails.env.production? ? 'https' : 'http'
    "#{prot}://#{Settings.blogine.host}/#{uri}"
  end

  def save_file(file)
    extname = file.content_type.match(/^image\/(gif|png|jpg|jpeg){1}$/).to_a[1]
    filename = File.basename(file.original_filename, '.*')
    uri = File.join('uploads', 'images', "#{DateTime.now.strftime('%Y/%m%d/%H%M%S')}_#{SecureRandom.hex(4)}.#{extname}")
    save_path = Rails.root.join('public', uri)
    file_dir = File.dirname(save_path)

    FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
    File.open save_path, 'wb' do |f|
      f.write(file.read)
    end
    prot = Rails.env.production? ? 'https' : 'http'
    "#{prot}://#{Settings.blogine.host}/#{uri}"
  end
end
