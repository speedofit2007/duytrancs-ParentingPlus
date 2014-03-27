class NotebooksController < ApplicationController
  before_filter :authenticate_user!
  def pull
    device = Device.where(:device => params[:device_id]).where(:user_id => current_user.id).first
    updated = Notebook.select("id, user_id, device_id, book_status, book_name, age, tokens").where(:user_id => current_user.id)
    deleted = DeletedNotebook.select("user_id,device_id,notebook_id")
    if device
      updated = updated.where("updated_at >= ? or created_at >= ?",device.last_sync,device.last_sync)
      deleted = deleted.where("created_at > ?",device.last_sync)
    end
    resp = { :updated => updated , :deleted => deleted }
    respond_to do |format|
      format.json  { render :json => resp }
    end
  end
  def push
    device = Device.where(:device => params[:device_id]).where(:user_id => current_user.id).first
    jsonData = Base64.decode64(params[:data])
    pushHash = JSON.load(jsonData)
    updated = pushHash["updated"]
    deleted = pushHash["deleted"]
    updated.each do |u|
      u['client_id'] = u['id'] # rename id to client_id in hash
      u.except!('id')
      logger.info "HERE WE ARE 1"
      notebook = Notebook.where('client_id = ? AND user_id = ? AND device_id = ?',u['client_id'],u['user_id'],u['device_id'])
      logger.info "HERE WE ARE 2"
      if notebook.count == 0
        logger.info "HERE WE ARE 3"
        logger.info "UPDATED(CREATE) " + u.slice(*Notebook.column_names).inspect
        n = Notebook.create(u.slice(*Notebook.column_names))
        n.client_id = u['id']
        n.save
      else
        logger.info "UPDATED(UPDATE) " + u.inspect
        notebook.first.update_attributes(u.slice(*(Notebook.column_names-['client_id','device_id','user_id'])))
      end
    end
    deleted.each do |d|
      notebook = Notebook.where('client_id = ? AND user_id = ? AND device_id = ?',d['id'],d['user_id'],d['device_id']).first
      if notebook != nil
        notebook.delete
      end
      logger.info "DELETED " + d.inspect
    end
    respond_to do |format|
      format.json  { render :json => nil }
    end
  end
end