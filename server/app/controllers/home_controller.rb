class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.all { render :nothing => true, :status => 200 }
    end
  end
  def syncBegin
    authenticate_user!
    @device = Device.where('user_id = ? AND device = ?',current_user.id,params[:device_id]).first
    if @device
      @device.current_sync = Time.now
      @device.save
    else
      @device = Device.new
      @device.last_sync = params[:last_sync]
      @device.current_sync = Time.now
      @device.device = params[:device_id]
      @device.user_id = current_user.id
      @device.save
    end
    respond_to do |format|
      format.json { render :json => @device }
    end
  end
  def syncEnd
    authenticate_user!
    @device = Device.where('user_id = ? AND device = ?',current_user.id,params[:device_id]).first
    if @device and @device.current_sync
      @device.last_sync = @device.current_sync
      @device.current_sync = nil
      @device.save
    end
    respond_to do |format|
      format.json { render :json => @device }
    end
  end
  def pull
    begin
      if params["object"] == "notebooks" or params["object"] == "rewards"
        params["object"] = params["object"].singularize
      end
      ActiveRecord::Base.record_timestamps = false
      object = Kernel.const_get params["object"].titleize
      deletedObject = Kernel.const_get "Deleted" + params["object"].titleize
      device = Device.where(:device => params[:device_id]).where(:user_id => current_user.id).first
      updated = object.select((object.column_names - ['client_id','picture']).join(',') + ',client_id AS id').where(:user_id => current_user.id)  
      deleted = deletedObject.select("user_id,device_id," + params["object"] + "_id AS id").where(:user_id => current_user.id) 
      if device
        if device.last_sync
          updated = updated.where("updated_at > ? or created_at > ?",device.last_sync,device.last_sync)
          deleted = deleted.where("created_at > ?",device.last_sync)
        end
        updated = updated.where("updated_at != ? AND created_at != ?",device.current_sync,device.current_sync)
        deleted = deleted.where("created_at != ?",device.current_sync)
      end
      resp = { :updated => updated , :deleted => deleted }
      respond_to do |format|
        format.json  { render :json => resp }
      end
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end
  def push
    begin
      if params["object"] == "notebooks" or params["object"] == "rewards"
        params["object"] = params["object"].singularize
      end
      ActiveRecord::Base.record_timestamps = false
      object = Kernel.const_get params["object"].titleize
      deletedObject = Kernel.const_get "Deleted" + params["object"].titleize
      device = Device.where(:device => params[:device_id]).where(:user_id => current_user.id).first
      jsonData = Base64.decode64(params[:data])
      pushHash = JSON.load(jsonData)
      updated = pushHash["updated"]
      deleted = pushHash["deleted"]
      updated.each do |u|
        u['client_id'] = u['id'] # rename id to client_id in hash
        u.except!('id')
        thisObject = object.where('client_id = ? AND user_id = ? AND device_id = ?',u['client_id'],u['user_id'],u['device_id']).first
        if thisObject == nil
          logger.info "UPDATED(CREATE) " + u.slice(*object.column_names).inspect
          n = object.new(u.slice(*object.column_names))
          n.created_at = n.updated_at = device.current_sync
          n.save
        else
          logger.info "UPDATED(UPDATE) " + u.inspect
          thisObject.update_attributes(u.slice(*(object.column_names-['client_id','device_id','user_id'])))
          thisObject.updated_at = device.current_sync
          thisObject.save
        end
      end
      deleted.each do |d|
        thisObject = object.where('client_id = ? AND user_id = ? AND device_id = ?',d['id'],d['user_id'],d['device_id']).first
        logger.info "***DELETE " + thisObject.inspect
        if thisObject != nil
          thisObject.delete
          deletedEntry = deletedObject.new({"#{params["object"]}_id" => d['id'], "user_id" => d['user_id'], "device_id" => d['device_id']})
          deletedEntry.created_at = deletedEntry.updated_at = device.current_sync
          deletedEntry.save
        end
        logger.info "DELETED " + d.inspect
      end
      respond_to do |format|
        format.json  { render :json => 'YES' }
      end
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end
  def syncPhoto
    authenticate_user!
    device = Device.where(:device => params[:device_id]).where(:user_id => current_user.id).first
    jsonData = Base64.decode64(params[:data])
    push = JSON.load(jsonData)
    pull = Notebook.select('client_id AS id,user_id,device_id,picture').where(:user_id => current_user).where("picture IS NOT NULL")
    if device.last_sync
      pull = pull.where('picture_updated > ?',device.last_sync)
    end
    pull = pull.all
    push.each do |p|
      n = Notebook.where('client_id = ? AND user_id = ? AND device_id = ?',p['id'],p['user_id'],p['device_id']).first
      if n.picture_updated == nil or device.last_sync == nil or n.picture_updated < device.last_sync
        n.picture_updated = Time.now
        n.picture = p['picture']
        n.save
      end
    end
    respond_to do |format|
      format.json  { render :json => pull }
    end
  end
end
