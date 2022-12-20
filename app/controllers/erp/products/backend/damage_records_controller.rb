module Erp
  module Products
    module Backend
      class DamageRecordsController < Erp::Backend::BackendController
        before_action :set_damage_record, only: [:show, :edit, :update, :damage_record_details,
                                                 :set_draft, :set_pending, :set_confirm, :set_delete,
                                                 :archive, :unarchive]
        before_action :set_damage_records, only: [:archive_all, :unarchive_all]

        # GET /damage_records
        def index
          authorize! :inventory_products_warehouse_checks_with_damage_index, nil
        end

        # POST /damage_records/list
        def list
          authorize! :inventory_products_warehouse_checks_with_damage_index, nil

          @damage_records = DamageRecord.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /damage record details
        def damage_record_details
          render layout: nil
        end

        # GET /damage_records/1
        def show
        end

        # GET /damage_records/new
        def new
          @damage_record = DamageRecord.new
          @damage_record.date = Time.now
          @damage_record.employee = current_user

          authorize! :create, @damage_record
        end

        # GET /damage_records/1/edit
        def edit
          authorize! :update, @damage_record
        end

        # POST /damage_records
        def create
          @damage_record = DamageRecord.new(damage_record_params)

          authorize! :create, @damage_record

          @damage_record.creator = current_user
          @damage_record.set_pending

          if @damage_record.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @damage_record.code,
                value: @damage_record.id
              }
            else
              redirect_to erp_products.edit_backend_damage_record_path(@damage_record), notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /damage_records/1
        def update
          authorize! :update, @damage_record

          if @damage_record.update(damage_record_params)

            # neu update thi phai duyet lai
            @damage_record.set_pending if @damage_record.is_done?

            if request.xhr?
              render json: {
                status: 'success',
                text: @damage_record.code,
                value: @damage_record.id
              }
            else
              redirect_to erp_products.edit_backend_damage_record_path(@damage_record), notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /damage_records/1
        #def destroy
        #  @damage_record.destroy
        #
        #  respond_to do |format|
        #    format.html { redirect_to erp_products.backend_damage_records_path, notice: t('.success') }
        #    format.json {
        #      render json: {
        #        'message': t('.success'),
        #        'type': 'success'
        #      }
        #    }
        #  end
        #end

        # Archive /damage_records/archive?id=1
        def archive
          @damage_record.archive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Unarchive /damage_records/unarchive?id=1
        def unarchive
          @damage_record.unarchive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # DELETE /damage_records/delete_all?ids=1,2,3
        #def delete_all
        #  @damage_records.destroy_all
        #
        #  respond_to do |format|
        #    format.json {
        #      render json: {
        #        'message': t('.success'),
        #        'type': 'success'
        #      }
        #    }
        #  end
        #end

        # Archive /damage_records/archive_all?ids=1,2,3
        def archive_all
          @damage_records.archive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Unarchive /damage_records/unarchive_all?ids=1,2,3
        def unarchive_all
          @damage_records.unarchive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Confirm /damage_records/set_draft?id=1
        def set_draft
          authorize! :set_draft, @damage_record

          @damage_record.set_draft

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Confirm /damage_records/set_pending?id=1
        def set_pending
          authorize! :set_pending, @damage_record

          @damage_record.set_pending

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Confirm /damage_records/set_confirm?id=1
        def set_confirm
          authorize! :set_done, @damage_record

          @damage_record.set_confirm
          @damage_record.update_confirmed_at

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Delete /damage_records/set_delete?id=1
        def set_delete
          authorize! :set_deleted, @damage_record

          @damage_record.set_delete

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        def dataselect
          respond_to do |format|
            format.json {
              render json: DamageRecord.dataselect(params[:keyword])
            }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_damage_record
            @damage_record = DamageRecord.find(params[:id])
          end

          def set_damage_records
            @damage_records = DamageRecord.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def damage_record_params
            params.fetch(:damage_record, {}).permit(:code, :date, :warehouse_id, :description, :employee_id,
                                            :damage_record_details_attributes => [ :id, :product_id, :damage_record_id, :quantity, :state_id, :note, :_destroy ])
          end
      end
    end
  end
end