DelayedPaperclip::Jobs::ActiveJob.class_eval do
  after_perform do |job|
    instance_klass = job.arguments.shift
    instance_id = job.arguments.shift
    instance_klass.constantize.unscoped.find(instance_id).delete_old_gif if instance_klass && instance_id
  end
end

