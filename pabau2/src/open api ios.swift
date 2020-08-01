openapi: 3.0.0
info:
  title: Pabau iOS
  description: |
    This is the Pabau iOS API.
  contact:
    email: andrej@pabau.com
  license:
    name: Apache 2.0
    url: http://www.apache.org/licenses/LICENSE-2.0.html
  version: 1.0.0
servers:
- url: https://crm.pabau.com
tags:
- name: Appointment
paths:
  /appointments/create_appointment_v1:
    post:
      tags:
      - Appointment
      summary: Creating an appointment
      parameters:
      - name: user_id
        in: query
        required: true
        style: form
        schema:
          type: integer
			- name: company
				in: query
				required: true
				style: form
        schema:
          type: integer
			- name: api_key
				in: query
				required: true
				style: form
				schema:
					type: string
			- name: app_version
				in: query
				required: true
				style: form
				schema:
					type: string
	 requestBody:
	   content:
		application/json:
		  schema:
		    type: object
		    properties:
				all_day:
			   type: boolean
				contact_id:
				 type: integer
			 start_time:
			   type: string
			   format: date
			 end_time:
			   type: string
			   format: date
			 sent_email:
			   type: boolean
			 send_sms:
			   type: boolean
			 sent_survey:
			   type: boolean
			 instant_sms:
			   type: boolean
				 insurance_company_id:
				   type: integer
				 insurance_contract_id
					type: integer
				 location_id:
					type: integer
				 membership_number:
					type: integer
				 room_id:
					type: integer
				 service_id:
					type: integer
				 status:
					type: string
				 uid:
					type: integer
      responses:
        "200":
          description: successful operation
          content:
            application/json:
              schema:
			  type: object
                properties:
                  success:
                    type: boolean
			    message:
				  type: string
                example:
                - success: true
                  message: “Appointment created successfuly”
  /appointments/get_appointments_v1:
    get:
      tags:
      - Journey
      summary: Used for getting appointments for the calendar feature.
      parameters:
      parameters:
      - name: user_id
        in: query
        required: true
        style: form
        schema:
          type: integer
			- name: company
				in: query
				required: true
				style: form
				schema:
					type: integer
			- name: api_key
				in: query
				required: true
				style: form
				schema:
					type: string
			- name: app_version
				in: query
				required: true
				style: form
				schema:
					type: string
      - name: start_date
        in: query
        style: form
        schema:
          type: string
		 format: date
      - name: end_date
        in: query
        style: form
        schema:
          type: string
					format: date
	- name: location_id
	  in: query
		style: form
	  explode: false
		schema:
			type: integer
	- name: user_ids
	  in: query
		style: form
		explode: false
		schema:
			type: integer
      responses:
        "200":
          description: successful operation
          content:
            application/json:
              schema:
                type: object
			  properties:
			    rota:
						type: object
						additionalProperties:
							$ref: '#/components/schemas/Shift'
					appointments:
						type: array
						items:
							$ref: '#/components/schemas/Appointment'
					success:
						type: boolean
					total:
						type: integer
					interval_setting
						type: integer
					start_time:
						type: string
						format: date
					end_time:
						type: string
						format: date
					complete_status_color:
						type: string
					checkin_status_color:
						type: string
        "404":
          description: That page was not found
components:
  schemas:
    Appointment:
      type: object
      properties:
        customer_name
				type: integer
        salutation
				type: integer
        id
				type: integer
        service
				type: integer
        user_id
				type: integer
        start_date
				type: integer
        start_time
				type: integer
        end_time
				type: integer
        appointment_status
				type: integer
        color
				type: integer
        service_id
				type: integer
        notes
				type: integer
        customer_id
				type: integer
        backgroudcolor
				type: integer
        create_date
				type: integer
        employee_name
				type: integer
        fname
				type: integer
        lname
				type: integer
				client_email
				type: integer
				mobile
				type: integer
				customer_address
				type: integer
				client_photo
				type: integer
				service_color
				type: integer
				location_id
				type: integer
				room_id
				type: integer
				room_name
				type: integer
				participant_user_ids
				type: array
				items:
					type: integer
				all_day
				type: boolean
				contract_id
				type: integer
				issued_to
				type: integer
				contact_id
				type: integer
				external_location
				type: integer
				private
				type: boolean
				description
				type: integer
				insurer_name
				type: integer
				charged_to
				type: integer
				total_yes
				type: integer
				total_no
				type: integer
				total_maybe
				type: integer
    Shift:
      type: object
      properties:
        id:
          type: integer
        employee_id:
          type: integer
        user_id:
          type: integer
        location_id:
          type: integer
        date:
          type: string
          format: date
        start_time:
          type: string
          format: date-time
        end_time:
          type: string
          format: date-time
        published:
          type: boolean
